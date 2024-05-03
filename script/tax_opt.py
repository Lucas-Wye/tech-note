import argparse
import numpy as np
from typing import Dict, Tuple

# ---------- 税率表 ----------
COMPREHENSIVE_TAX_BRACKETS = [
    (0, 36000, 3, 0),
    (36000, 144000, 10, 2520),
    (144000, 300000, 20, 16920),
    (300000, 420000, 25, 31920),
    (420000, 660000, 30, 52920),
    (660000, 960000, 35, 85920),
    (960000, float("inf"), 45, 181920),
]
BONUS_TAX_BRACKETS = [
    (0, 3000, 3, 0),
    (3000, 12000, 10, 210),
    (12000, 25000, 20, 1410),
    (25000, 35000, 25, 2660),
    (35000, 55000, 30, 4410),
    (55000, 80000, 35, 7160),
    (80000, float("inf"), 45, 15160),
]


def calc_income_tax(income: float) -> float:
    if income <= 0:
        return 0.0
    for low, high, rate, deduction in COMPREHENSIVE_TAX_BRACKETS:
        if low < income <= high:
            return round(income * rate / 100 - deduction + 1e-8, 2)
    return 0.0


def calc_bonus_tax(bonus):
    if bonus <= 0:
        return 0.0
    monthly = bonus / 12.0
    for low, high, rate, deduction in BONUS_TAX_BRACKETS:
        if low < monthly <= high:
            return round(bonus * rate / 100 - deduction + 1e-8, 2)
    return 0.0


def calc_all(
    annual_income,
    bonus,
    social_insurance_annual_max,
    medical_annual_max,
    unemployment_annual_max,
    social_insurance_rate,
    medical_rate,
    unemployment_rate,
    fund_base_method,
    housing_fund_annual_max,
    housing_fund_rate,
    other_deductions,
    bonus_method,
    basic_deduction,
    special_add_deduction,
):
    salary = annual_income - bonus

    # 社保（仅基于工资部分）
    ins_base = (
        min(salary, social_insurance_annual_max)
        if social_insurance_annual_max
        else salary
    )
    med_base = min(salary, medical_annual_max) if medical_annual_max else salary
    unemp_base = (
        min(salary, unemployment_annual_max) if unemployment_annual_max else salary
    )
    ins_si = ins_base * social_insurance_rate
    med_si = med_base * medical_rate
    unemp_si = unemp_base * unemployment_rate
    si = ins_si + med_si + unemp_si

    # 公积金基数
    if fund_base_method == "salary_only":
        fb = min(salary, housing_fund_annual_max) if housing_fund_annual_max else salary
    else:
        fb = (
            min(annual_income, housing_fund_annual_max)
            if housing_fund_annual_max
            else annual_income
        )
    hp = fb * housing_fund_rate  # 个人部分
    hc = hp  # 单位部分（假设1:1配比）

    ded = si + hp + other_deductions  # 三险一金+其他扣除
    # 计税
    sti = 0.0
    tti = 0.0
    if bonus_method == "separate":
        sti = max(0.0, salary - ded - basic_deduction - special_add_deduction)
        st = calc_income_tax(sti)
        bt = calc_bonus_tax(bonus)
        tt = st + bt
    else:
        tti = max(0.0, annual_income - ded - basic_deduction - special_add_deduction)
        tt = calc_income_tax(tti)
        st = tt
        bt = 0.0

    # 总收益 = 税后到手现金 + 个人公积金 + 单位公积金
    cash = annual_income - ded - tt
    benefit = cash + hp + hc
    return (
        benefit,
        salary,
        si,
        ins_si,
        med_si,
        unemp_si,
        hc,
        hp,
        fb,
        sti,
        tti,
        st,
        bt,
        tt,
        cash,
    )


def optimize_total_package(
    # 年度总收入（税前）
    annual_income: float,
    # 社保相关（仅基于工资部分）
    social_insurance_rate: float,  # 养老保险个人比例
    medical_rate: float,  # 医疗保险
    unemployment_rate: float,  # 失业保险
    # 公积金个人费率
    housing_fund_rate: float,
    # 其他税前扣除（企业年金等）
    other_deductions: float,
    # 个税基本减除费用
    basic_deduction: float,
    # 专项附加扣除年度总额
    special_add_deduction: float,
    # 分配搜索步长
    step: float,
    # "separate" (单独计税) / "combined" (并入综合所得)
    bonus_method: str,
    # "full" (全年总收入) / "salary_only" (不算年终奖的收入)
    fund_base_method: str,
    # 社保月缴费基数上限（可设为 None 表示不设限）
    social_insurance_annual_max: float = None,
    medical_annual_max: float = None,
    unemployment_annual_max: float = None,
    # 公积金月缴费基数上限
    housing_fund_annual_max: float = None,
) -> Dict:
    """优化薪酬结构，最大化个人总收益（税后现金 + 个人公积金 + 单位公积金）"""
    best_plan = {}
    best_val = -float("inf")
    n = int(annual_income / step) + 1
    for i in range(n):
        bonus = round(i * step, 2)

        (
            benefit,
            salary,
            si,
            ins_si,
            med_si,
            unemp_si,
            hc,
            hp,
            fb,
            sti,
            tti,
            st,
            bt,
            tt,
            cash,
        ) = calc_all(
            annual_income,
            bonus,
            social_insurance_annual_max,
            medical_annual_max,
            unemployment_annual_max,
            social_insurance_rate,
            medical_rate,
            unemployment_rate,
            fund_base_method,
            housing_fund_annual_max,
            housing_fund_rate,
            other_deductions,
            bonus_method,
            basic_deduction,
            special_add_deduction,
        )

        if benefit > best_val:
            best_val = benefit
            best_plan = dict(
                annual_income=annual_income,
                monthly_base_salary=round(salary / 12, 2),
                annual_bonus=bonus,
                social_insurance_monthly=round(si / 12, 2),
                social_insurance_detail=dict(
                    pension_monthly=round(ins_si / 12, 2),
                    medical_monthly=round(med_si / 12, 2),
                    unemployment_monthly=round(unemp_si / 12, 2),
                ),
                housing_fund_monthly=round(hp / 12, 2),
                company_housing_fund_monthly=round(hc / 12, 2),
                fund_base_monthly=round(fb / 12, 2),
                taxable_income=round(sti if bonus_method == "separate" else tti, 2),
                salary_tax=st,
                bonus_tax=bt,
                total_tax=round(tt, 2),
                after_tax_cash=round(cash, 2),
                total_housing_fund=round(hp + hc, 2),
                total_benefit=round(benefit, 2),
            )
    return best_plan


def _print_result(res: dict, args) -> None:
    """统一输出月度明细：社保、公积金、五险一金、个税、到手收入"""
    si = res["social_insurance_monthly"]
    si_d = res.get("social_insurance_detail", {})
    hp = res["housing_fund_monthly"]
    hc = res["company_housing_fund_monthly"]
    base = res["monthly_base_salary"]
    bonus = res["annual_bonus"]
    st = res["salary_tax"]
    bt = res["bonus_tax"]
    tt = res["total_tax"]
    cash = res["after_tax_cash"]
    benefit = res["total_benefit"]
    fund_base = res.get("fund_base_monthly", base)

    # 月均工资个税（近似值）
    monthly_st = round(st / 12 if st else 0, 2)
    # 非年终奖月份月到手 = 月Base - 社保 - 公积金 - 月均个税
    monthly_net = round(base - si - hp - monthly_st, 2)
    # 年终奖到手 = 年终奖 - 社保 - 公积金 - 月均个税 - 年终奖个税
    bonus_net = round(bonus - bt, 2)

    tax_method = "年终奖单独计税" if bt > 0 else "并入综合所得"
    fund_method = "全年总收入" if args.fund_base == "full" else "不含年终奖"
    d = "-" * 46

    print(f"\n{'=' * 54}")
    print(f"  薪酬结构优化方案")
    print(f"{'=' * 54}")
    print(f"计税方式:    {tax_method}        公积金基数: {fund_method}")
    print(d)
    print(f"【年度概况】")
    print(f"  年度总收入(税前):           {res['annual_income']:>10,.2f}")
    print(f"  年度五险一金(个人):         {si + hp:>10,.2f}")
    print(f"  年度个税合计:               {tt:>10,.2f}")
    print(f"  年度税后现金:               {cash:>10,.2f}")
    print(f"  年度公积金(单位+个人):      {res['total_housing_fund']:>10,.2f}")
    print(f"  年度总收益(含公积金):       {benefit:>10,.2f}")
    print(d)
    print(f"【月度社保明细】")
    if si_d:
        print(f"  养老保险(个人):     {si_d['pension_monthly']:>8,.2f}")
        print(f"  医疗保险(个人):     {si_d['medical_monthly']:>8,.2f}")
        print(f"  失业保险(个人):     {si_d['unemployment_monthly']:>8,.2f}")
    print(f"  社保合计(个人):     {si:>8,.2f}")
    print(d)
    print(f"【月度公积金明细】")
    print(f"  缴费基数:           {fund_base:>8,.2f}")
    print(f"  个人缴存:           {hp:>8,.2f}")
    print(f"  单位缴存:           {hc:>8,.2f}")
    print(f"  合计:               {hp + hc:>8,.2f}")
    print(d)
    print(f"【月度税前扣除合计】")
    print(f"  五险一金(个人):     {si + hp:>8,.2f}  = {si} + {hp}")
    print(d)
    print(f"【个税明细】")
    if "taxable_income" in res:
        print(f"  工资应纳税所得额:   {res['taxable_income']:>10,.2f}")
    print(f"  工资个税(年度):     {st:>10,.2f}    月均: {monthly_st:>8,.2f}")
    print(f"  年终奖个税:         {bt:>10,.2f}")
    print(f"  个税合计(年度):     {tt:>10,.2f}")
    print(d)
    print(f"【到手收入】")
    print(f"  每月:       {base:>10,.2f} -> {monthly_net:>10,.2f}")
    print(f"  年终奖:     {bonus:>10,.2f} -> {bonus_net:>10,.2f}")
    print(f"{'=' * 54}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="个人所得税综合与年终奖优化工具")
    parser.add_argument("--no-calc", action="store_true", help="是否不计算最优薪酬结构")
    parser.add_argument("--bonus", type=float, help="年终奖（税前）")
    parser.add_argument(
        "--annual-income", type=float, required=True, help="年度总收入（税前）"
    )
    parser.add_argument(
        "--social-ins-rate", type=float, default=0.08, help="养老保险个人比例"
    )
    parser.add_argument(
        "--medical-rate", type=float, default=0.02, help="医疗保险个人比例"
    )
    parser.add_argument(
        "--unemployment-rate", type=float, default=0.005, help="失业保险个人比例"
    )
    parser.add_argument("--fund-rate", type=float, default=0.12, help="公积金个人比例")
    parser.add_argument(
        "--ins-max", type=float, default=27549, help="社保月缴费基数上限"
    )
    parser.add_argument(
        "--med-max", type=float, default=33633, help="医疗保险月缴费基数上限"
    )
    parser.add_argument(
        "--unem-max", type=float, default=44265, help="失业保险月缴费基数上限"
    )
    parser.add_argument(
        "--fund-max", type=float, default=44265, help="公积金月缴费基数上限"
    )
    parser.add_argument(
        "--other-deductions", type=float, default=0.0, help="其他税前扣除"
    )
    parser.add_argument(
        "--basic-deduction", type=float, default=60000, help="基本减除费用"
    )
    parser.add_argument(
        "--special-add-deduction", type=float, default=30000, help="专项附加扣除"
    )
    parser.add_argument("--step", type=float, default=500, help="搜索步长")
    parser.add_argument(
        "--bonus-method",
        choices=["separate", "combined"],
        default="separate",
        help='年终奖计税方式: "separate" (单独计税) / "combined" (并入综合所得)',
    )
    parser.add_argument(
        "--fund-base",
        choices=["full", "salary_only"],
        default="salary_only",
        help='公积金基数计算方式: "full" (全年总收入) / "salary_only" (不算年终奖)',
    )
    args = parser.parse_args()

    print(args.no_calc)
    if not args.no_calc:
        res = optimize_total_package(
            annual_income=args.annual_income,
            social_insurance_rate=args.social_ins_rate,
            medical_rate=args.medical_rate,
            unemployment_rate=args.unemployment_rate,
            housing_fund_rate=args.fund_rate,
            social_insurance_annual_max=args.ins_max * 12,
            medical_annual_max=args.med_max * 12,
            unemployment_annual_max=args.unem_max * 12,
            housing_fund_annual_max=args.fund_max * 12,
            other_deductions=args.other_deductions,
            basic_deduction=args.basic_deduction,
            special_add_deduction=args.special_add_deduction,
            step=args.step,
            bonus_method=args.bonus_method,
            fund_base_method=args.fund_base,
        )

        _print_result(res, args)
    else:
        (
            benefit,
            salary,
            si,
            ins_si,
            med_si,
            unemp_si,
            hc,
            hp,
            fb,
            sti,
            tti,
            st,
            bt,
            tt,
            cash,
        ) = calc_all(
            annual_income=args.annual_income,
            bonus=args.bonus,
            social_insurance_annual_max=args.ins_max * 12,
            medical_annual_max=args.med_max * 12,
            unemployment_annual_max=args.unem_max * 12,
            social_insurance_rate=args.social_ins_rate,
            medical_rate=args.medical_rate,
            unemployment_rate=args.unemployment_rate,
            fund_base_method=args.fund_base,
            housing_fund_annual_max=args.fund_max * 12,
            housing_fund_rate=args.fund_rate,
            other_deductions=args.other_deductions,
            bonus_method=args.bonus_method,
            basic_deduction=args.basic_deduction,
            special_add_deduction=args.special_add_deduction,
        )
        res = dict(
            annual_income=args.annual_income,
            monthly_base_salary=round(salary / 12, 2),
            annual_bonus=args.bonus,
            social_insurance_monthly=round(si / 12, 2),
            social_insurance_detail=dict(
                pension_monthly=round(ins_si / 12, 2),
                medical_monthly=round(med_si / 12, 2),
                unemployment_monthly=round(unemp_si / 12, 2),
            ),
            housing_fund_monthly=round(hp / 12, 2),
            company_housing_fund_monthly=round(hc / 12, 2),
            fund_base_monthly=round(fb / 12, 2),
            taxable_income=round(sti if args.bonus_method == "separate" else tti, 2),
            salary_tax=st,
            bonus_tax=bt,
            total_tax=round(tt, 2),
            after_tax_cash=round(cash, 2),
            total_housing_fund=round(hp + hc, 2),
            total_benefit=round(benefit, 2),
        )
        _print_result(res, args)

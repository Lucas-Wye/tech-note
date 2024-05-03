import pandas as pd
import numpy as np
import akshare as ak
import matplotlib.pyplot as plt
import warnings
from datetime import datetime, timedelta

warnings.filterwarnings("ignore")
plt.rcParams["font.sans-serif"] = ["SimHei"]  # 用来正常显示中文标签
plt.rcParams["axes.unicode_minus"] = False  # 用来正常显示负号
plt.style.use("seaborn-v0_8-darkgrid")


class FundBacktest:
    def __init__(
        self,
        fund_code,
        start_date,
        end_date,
        investment_amount=1000,
        data_source="akshare",
    ):
        """
        初始化回测参数

        Parameters:
        -----------
        fund_code : str
            基金代码（示例：'000001' 为华夏成长混合）
        start_date : str
            开始日期，格式：'YYYY-MM-DD'
        end_date : str
            结束日期，格式：'YYYY-MM-DD'
        investment_amount : float
            每次定投金额
        data_source : str
            数据源：'akshare', 'tushare', 'baostock'
        """
        self.fund_code = fund_code
        self.start_date = start_date
        self.end_date = end_date
        self.investment_amount = investment_amount
        self.data_source = data_source

    def fetch_data_akshare(self):
        """使用Akshare获取基金历史数据"""
        print(f"正在使用Akshare获取基金 {self.fund_code} 的历史数据...")

        # 获取基金历史净值数据
        fund_df = ak.fund_open_fund_info_em(self.fund_code, indicator="单位净值走势")

        if fund_df.empty:
            raise ValueError("未获取到数据，请检查基金代码是否正确")

        # 重命名列
        fund_df = fund_df.rename(
            columns={"净值日期": "date", "单位净值": "nav", "日增长率": "daily_return"}
        )

        # 转换日期格式
        fund_df["date"] = pd.to_datetime(fund_df["date"])
        fund_df.set_index("date", inplace=True)

        # 按日期排序
        fund_df = fund_df.sort_index()

        # 筛选日期范围
        mask = (fund_df.index >= pd.to_datetime(self.start_date)) & (
            fund_df.index <= pd.to_datetime(self.end_date)
        )
        fund_df = fund_df.loc[mask]

        # 只保留净值数据
        fund_df = fund_df[["nav"]].copy()

        print(
            f"数据获取成功！时间段：{fund_df.index[0].date()} 至 {fund_df.index[-1].date()}"
        )
        print(f"交易日总数：{len(fund_df)}")
        print(f"最新净值：{fund_df['nav'].iloc[-1]:.4f}")

        return fund_df

    def fetch_data_tushare(self):
        """使用Tushare获取数据（需要token）"""
        import tushare as ts

        # 设置token（需要先注册tushare账号获取token）
        ts_token = "你的tushare_token"  # 请替换为你的token
        ts.set_token(ts_token)
        pro = ts.pro_api()

        print(f"正在使用Tushare获取基金 {self.fund_code} 的历史数据...")

        # 获取基金净值数据
        df = pro.fund_nav(
            ts_code=self.fund_code,
            start_date=self.start_date.replace("-", ""),
            end_date=self.end_date.replace("-", ""),
        )

        if df.empty:
            # 如果是ETF，尝试用基金日线行情接口
            df = pro.fund_daily(
                ts_code=self.fund_code,
                start_date=self.start_date.replace("-", ""),
                end_date=self.end_date.replace("-", ""),
            )
            df = df.rename(columns={"trade_date": "end_date", "close": "nav"})

        df["date"] = pd.to_datetime(df["end_date"])
        df.set_index("date", inplace=True)
        df = df.sort_index()
        df = df[["nav"]].copy()

        return df

    def fetch_data_baostock(self):
        """使用Baostock获取数据（适合指数基金）"""
        import baostock as bs

        print(f"正在使用Baostock获取 {self.fund_code} 的历史数据...")

        # 登录Baostock
        lg = bs.login()

        # 获取指数或股票数据（如果是ETF，通常以'sh.'或'sz.'开头）
        if self.fund_code.startswith("sh.") or self.fund_code.startswith("sz."):
            code = self.fund_code
        elif self.fund_code.startswith("5"):
            code = f"sh.{self.fund_code}"  # 上海ETF
        elif self.fund_code.startswith("1"):
            code = f"sz.{self.fund_code}"  # 深圳ETF
        else:
            code = f"sh.{self.fund_code}"  # 默认上海

        rs = bs.query_history_k_data_plus(
            code,
            "date,close",
            start_date=self.start_date,
            end_date=self.end_date,
            frequency="d",
            adjustflag="3",
        )  # 复权

        data_list = []
        while (rs.error_code == "0") & rs.next():
            data_list.append(rs.get_row_data())

        bs.logout()

        df = pd.DataFrame(data_list, columns=["date", "nav"])
        df["date"] = pd.to_datetime(df["date"])
        df.set_index("date", inplace=True)
        df["nav"] = df["nav"].astype(float)

        return df

    def fetch_data(self):
        """获取基金历史数据（多数据源尝试）"""
        data = None

        if self.data_source == "akshare":
            data = self.fetch_data_akshare()
        elif self.data_source == "tushare":
            data = self.fetch_data_tushare()
        elif self.data_source == "baostock":
            data = self.fetch_data_baostock()

        # 如果指定数据源失败，尝试其他数据源
        if data is None:
            print("\n尝试使用Akshare获取数据...")
            data = self.fetch_data_akshare()

        if data is None:
            print("\n尝试使用Baostock获取数据...")
            data = self.fetch_data_baostock()

        return data

    def daily_dca(self, data):
        """每日定投策略"""
        data_daily = data.copy()
        data_daily["investment"] = self.investment_amount
        data_daily["shares_bought"] = data_daily["investment"] / data_daily["nav"]
        data_daily["cumulative_shares"] = data_daily["shares_bought"].cumsum()
        data_daily["cumulative_investment"] = data_daily["investment"].cumsum()
        data_daily["portfolio_value"] = (
            data_daily["cumulative_shares"] * data_daily["nav"]
        )
        data_daily["return_rate"] = (
            data_daily["portfolio_value"] - data_daily["cumulative_investment"]
        ) / data_daily["cumulative_investment"]

        return data_daily

    def weekly_tue_thu_dca(self, data, invest_days=[1, 3]):
        """每周二、周四定投策略（默认）"""
        data_weekly = data.copy()

        # 标记周二和周四（0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, 4=Friday）
        data_weekly["day_of_week"] = data_weekly.index.dayofweek

        # 创建投资列，只在周二或周四投资
        data_weekly["investment"] = np.where(
            data_weekly["day_of_week"].isin(invest_days),  # 1=Tuesday, 3=Thursday
            self.investment_amount,
            0,
        )

        # 计算每次购买的份额
        data_weekly["shares_bought"] = np.where(
            data_weekly["investment"] > 0,
            data_weekly["investment"] / data_weekly["nav"],
            0,
        )

        # 计算累计份额和投资
        data_weekly["cumulative_shares"] = data_weekly["shares_bought"].cumsum()
        data_weekly["cumulative_investment"] = data_weekly["investment"].cumsum()

        # 计算投资组合价值
        data_weekly["portfolio_value"] = (
            data_weekly["cumulative_shares"] * data_weekly["nav"]
        )

        # 计算收益率
        data_weekly["return_rate"] = np.where(
            data_weekly["cumulative_investment"] > 0,
            (data_weekly["portfolio_value"] - data_weekly["cumulative_investment"])
            / data_weekly["cumulative_investment"],
            0,
        )

        return data_weekly

    def monthly_dca(self, data, day_of_month=1):
        """每月定投策略（作为额外对比）"""
        data_monthly = data.copy()

        # 获取每月的第一天（或指定日期）
        data_monthly["day_of_month"] = data_monthly.index.day
        data_monthly["month"] = data_monthly.index.month
        data_monthly["year"] = data_monthly.index.year

        # 标记每月定投日
        # 如果指定日期不是交易日，则使用当月第一个交易日
        monthly_investment_days = []
        for (year, month), group in data_monthly.groupby(["year", "month"]):
            # 先尝试找指定日期
            target_day = group[group["day_of_month"] == day_of_month]
            if not target_day.empty:
                monthly_investment_days.append(target_day.index[0])
            else:
                # 如果指定日期不是交易日，使用当月第一个交易日
                monthly_investment_days.append(group.index[0])

        # 创建投资列
        data_monthly["investment"] = 0
        data_monthly.loc[monthly_investment_days, "investment"] = self.investment_amount

        # 计算每次购买的份额
        data_monthly["shares_bought"] = data_monthly["investment"] / data_monthly["nav"]

        # 计算累计份额和投资
        data_monthly["cumulative_shares"] = data_monthly["shares_bought"].cumsum()
        data_monthly["cumulative_investment"] = data_monthly["investment"].cumsum()

        # 计算投资组合价值
        data_monthly["portfolio_value"] = (
            data_monthly["cumulative_shares"] * data_monthly["nav"]
        )

        # 计算收益率
        data_monthly["return_rate"] = np.where(
            data_monthly["cumulative_investment"] > 0,
            (data_monthly["portfolio_value"] - data_monthly["cumulative_investment"])
            / data_monthly["cumulative_investment"],
            0,
        )

        return data_monthly

    def calculate_metrics(self, strategy_data, strategy_name):
        """计算策略的关键指标"""
        final_value = strategy_data["portfolio_value"].iloc[-1]
        total_investment = strategy_data["cumulative_investment"].iloc[-1]
        total_return = final_value - total_investment
        return_rate = total_return / total_investment

        # 计算年化收益率
        days = (strategy_data.index[-1] - strategy_data.index[0]).days
        years = days / 365.25
        annualized_return = (1 + return_rate) ** (1 / years) - 1 if years > 0 else 0

        # 统计投资次数
        investment_count = (strategy_data["investment"] > 0).sum()

        # 计算最大回撤
        strategy_data["cumulative_max"] = strategy_data["portfolio_value"].cummax()
        strategy_data["drawdown"] = (
            strategy_data["portfolio_value"] - strategy_data["cumulative_max"]
        ) / strategy_data["cumulative_max"]
        max_drawdown = strategy_data["drawdown"].min()

        # 计算夏普比率（假设无风险收益率为3%）
        if len(strategy_data) > 1:
            daily_returns = strategy_data["portfolio_value"].pct_change().dropna()
            if len(daily_returns) > 0:
                risk_free_rate = 0.03 / 365  # 日化无风险利率
                excess_returns = daily_returns - risk_free_rate
                sharpe_ratio = (
                    np.sqrt(252) * excess_returns.mean() / daily_returns.std()
                    if daily_returns.std() != 0
                    else 0
                )
            else:
                sharpe_ratio = 0
        else:
            sharpe_ratio = 0

        metrics = {
            "策略名称": strategy_name,
            "总投资次数": int(investment_count),
            "总投入金额": round(total_investment, 2),
            "最终资产价值": round(final_value, 2),
            "总收益": round(total_return, 2),
            "总收益率": f"{return_rate * 100:.2f}%",
            "年化收益率": f"{annualized_return * 100:.2f}%",
            "最大回撤": f"{max_drawdown * 100:.2f}%",
            "夏普比率": f"{sharpe_ratio:.2f}",
        }

        return metrics

    def run_backtest(self):
        """运行回测"""
        # 获取数据
        data = self.fetch_data()
        if data is None:
            print("无法获取数据，请检查网络连接或基金代码")
            return None

        print("\n" + "=" * 60)
        print("开始回测...")
        print(f"回测期间: {self.start_date} 至 {self.end_date}")
        print(f"每次定投金额: ¥{self.investment_amount}")
        print(f"初始净值: {data['nav'].iloc[0]:.4f}")
        print(f"最终净值: {data['nav'].iloc[-1]:.4f}")
        print(
            f"净值涨跌幅: {(data['nav'].iloc[-1] / data['nav'].iloc[0] - 1) * 100:.2f}%"
        )
        print("=" * 60)

        # 执行策略
        daily_results = self.daily_dca(data)
        weekly_2_4_results = self.weekly_tue_thu_dca(data)
        weekly_4_results = self.weekly_tue_thu_dca(data, invest_days=[3])
        monthly_results = self.monthly_dca(data, day_of_month=1)

        # 计算指标
        daily_metrics = self.calculate_metrics(daily_results, "每日定投")
        weekly_2_4_metrics = self.calculate_metrics(weekly_2_4_results, "周二+周四定投")
        weekly_4_metrics = self.calculate_metrics(weekly_4_results, "周四定投")
        monthly_metrics = self.calculate_metrics(monthly_results, "每月1日定投")

        # 计算策略间的差异
        daily_final = float(daily_metrics["最终资产价值"])
        weekly_2_4_final = float(weekly_2_4_metrics["最终资产价值"])
        weekly_4_final = float(weekly_4_metrics["最终资产价值"])
        monthly_final = float(monthly_metrics["最终资产价值"])

        comparison_df = pd.DataFrame(
            [daily_metrics, weekly_2_4_metrics, weekly_4_metrics, monthly_metrics]
        )

        print("\n📊 策略回测结果对比:")
        print(comparison_df)

        # 可视化结果
        # self.plot_results(daily_results, weekly_2_4_results, monthly_results,
        #                  daily_metrics, weekly_2_4_metrics, monthly_metrics)

        # 保存结果到Excel
        # self.save_results(daily_results, weekly_2_4_results, monthly_results, comparison_df)

        return {
            "daily": daily_results,
            "weekly_2_4": weekly_2_4_results,
            "weekly_4": weekly_4_results,
            "monthly": monthly_results,
        }

    def plot_results(
        self,
        daily_data,
        weekly_data,
        monthly_data,
        daily_metrics,
        weekly_2_4_metrics,
        monthly_metrics,
    ):
        """绘制回测结果图表"""
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle(
            f"基金定投策略回测分析 ({self.start_date} 至 {self.end_date})",
            fontsize=16,
            fontweight="bold",
        )

        # 1. 资产增长曲线
        ax1 = axes[0, 0]
        ax1.plot(
            daily_data.index,
            daily_data["portfolio_value"],
            label=f"每日定投",
            linewidth=2,
            alpha=0.8,
        )
        ax1.plot(
            weekly_data.index,
            weekly_data["portfolio_value"],
            label=f"周二+周四定投",
            linewidth=2,
            alpha=0.8,
        )
        ax1.plot(
            monthly_data.index,
            monthly_data["portfolio_value"],
            label=f"每月1日定投",
            linewidth=2,
            alpha=0.8,
        )
        ax1.set_title("投资组合价值增长曲线", fontsize=14, fontweight="bold")
        ax1.set_xlabel("日期")
        ax1.set_ylabel("投资组合价值 (元)")
        ax1.legend()
        ax1.grid(True, alpha=0.3)

        # 2. 累计投入金额对比
        ax2 = axes[0, 1]
        ax2.plot(
            daily_data.index,
            daily_data["cumulative_investment"],
            label="每日定投",
            linewidth=2,
        )
        ax2.plot(
            weekly_data.index,
            weekly_data["cumulative_investment"],
            label="周二+周四定投",
            linewidth=2,
        )
        ax2.plot(
            monthly_data.index,
            monthly_data["cumulative_investment"],
            label="每月1日定投",
            linewidth=2,
        )
        ax2.set_title("累计投入金额对比", fontsize=14, fontweight="bold")
        ax2.set_xlabel("日期")
        ax2.set_ylabel("累计投入金额 (元)")
        ax2.legend()
        ax2.grid(True, alpha=0.3)

        # 3. 收益率对比
        ax3 = axes[1, 0]
        ax3.plot(
            daily_data.index,
            daily_data["return_rate"] * 100,
            label="每日定投",
            linewidth=2,
            alpha=0.7,
        )
        ax3.plot(
            weekly_data.index,
            weekly_data["return_rate"] * 100,
            label="周二+周四定投",
            linewidth=2,
            alpha=0.7,
        )
        ax3.plot(
            monthly_data.index,
            monthly_data["return_rate"] * 100,
            label="每月1日定投",
            linewidth=2,
            alpha=0.7,
        )
        ax3.set_title("累计收益率对比", fontsize=14, fontweight="bold")
        ax3.set_xlabel("日期")
        ax3.set_ylabel("累计收益率 (%)")
        ax3.legend()
        ax3.grid(True, alpha=0.3)

        # 4. 策略对比柱状图
        ax4 = axes[1, 1]
        strategies = ["每日定投", "周二+周四定投", "每月1日定投"]
        final_values = [
            float(daily_metrics["最终资产价值"]),
            float(weekly_2_4_metrics["最终资产价值"]),
            float(monthly_metrics["最终资产价值"]),
        ]
        returns = [
            float(daily_metrics["总收益率"].strip("%")),
            float(weekly_2_4_metrics["总收益率"].strip("%")),
            float(monthly_metrics["总收益率"].strip("%")),
        ]

        x = np.arange(len(strategies))
        width = 0.35

        bars1 = ax4.bar(
            x - width / 2,
            final_values,
            width,
            label="最终资产价值",
            color="skyblue",
            alpha=0.8,
        )
        ax4_twin = ax4.twinx()
        bars2 = ax4_twin.bar(
            x + width / 2,
            returns,
            width,
            label="总收益率",
            color="lightcoral",
            alpha=0.8,
        )

        ax4.set_title("策略最终表现对比", fontsize=14, fontweight="bold")
        ax4.set_xticks(x)
        ax4.set_xticklabels(strategies)
        ax4.set_ylabel("最终资产价值 (元)")
        ax4_twin.set_ylabel("总收益率 (%)")

        # 添加数值标签
        for i, v in enumerate(final_values):
            ax4.text(
                i - width / 2,
                v * 1.01,
                f"¥{v:,.0f}",
                ha="center",
                va="bottom",
                fontweight="bold",
                fontsize=9,
            )

        for i, v in enumerate(returns):
            ax4_twin.text(
                i + width / 2,
                v * 1.01,
                f"{v:.1f}%",
                ha="center",
                va="bottom",
                fontweight="bold",
                fontsize=9,
            )

        # 合并图例
        lines1, labels1 = ax4.get_legend_handles_labels()
        lines2, labels2 = ax4_twin.get_legend_handles_labels()
        ax4.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

        plt.tight_layout()

        # 保存图表
        plt.savefig(
            f"fund_dca_backtest_{self.fund_code}.png", dpi=300, bbox_inches="tight"
        )
        plt.show()

        # 额外绘制净值走势和回撤图
        fig2, (ax5, ax6) = plt.subplots(2, 1, figsize=(14, 10))

        # 净值走势
        ax5.plot(
            daily_data.index,
            daily_data["nav"],
            label="基金净值",
            color="green",
            linewidth=2,
        )
        ax5.set_title("基金净值走势", fontsize=14, fontweight="bold")
        ax5.set_xlabel("日期")
        ax5.set_ylabel("净值")
        ax5.legend()
        ax5.grid(True, alpha=0.3)

        # 回撤图
        ax6.fill_between(
            daily_data.index,
            0,
            daily_data["drawdown"] * 100,
            color="red",
            alpha=0.3,
            label="回撤",
        )
        ax6.plot(
            daily_data.index, daily_data["drawdown"] * 100, color="red", linewidth=1
        )
        ax6.set_title("投资组合回撤分析", fontsize=14, fontweight="bold")
        ax6.set_xlabel("日期")
        ax6.set_ylabel("回撤幅度 (%)")
        ax6.legend()
        ax6.grid(True, alpha=0.3)
        ax6.invert_yaxis()  # 回撤图通常Y轴倒置

        plt.tight_layout()
        plt.savefig(f"fund_analysis_{self.fund_code}.png", dpi=300, bbox_inches="tight")
        plt.show()

    def save_results(self, daily_data, weekly_data, monthly_data, metrics_df):
        """保存回测结果到Excel"""
        with pd.ExcelWriter(
            f"fund_backtest_results_{self.fund_code}.xlsx", engine="openpyxl"
        ) as writer:
            # 保存净值数据
            nav_data = pd.DataFrame(
                {"日期": daily_data.index, "基金净值": daily_data["nav"]}
            )
            nav_data.to_excel(writer, sheet_name="净值数据", index=False)

            # 保存各策略详细数据
            daily_summary = daily_data[
                ["nav", "investment", "portfolio_value", "return_rate"]
            ].copy()
            daily_summary.columns = ["净值", "投资金额", "组合价值", "收益率"]
            daily_summary.to_excel(writer, sheet_name="每日定投详情")

            weekly_summary = weekly_data[
                ["nav", "investment", "portfolio_value", "return_rate"]
            ].copy()
            weekly_summary.columns = ["净值", "投资金额", "组合价值", "收益率"]
            weekly_summary.to_excel(writer, sheet_name="周二周四定投详情")

            monthly_summary = monthly_data[
                ["nav", "investment", "portfolio_value", "return_rate"]
            ].copy()
            monthly_summary.columns = ["净值", "投资金额", "组合价值", "收益率"]
            monthly_summary.to_excel(writer, sheet_name="每月定投详情")

            # 保存指标对比
            metrics_df.to_excel(writer, sheet_name="策略对比", index=False)

            # 添加回测参数信息
            params_df = pd.DataFrame(
                {
                    "参数": [
                        "基金代码",
                        "开始日期",
                        "结束日期",
                        "每次定投金额",
                        "数据源",
                    ],
                    "值": [
                        self.fund_code,
                        self.start_date,
                        self.end_date,
                        f"¥{self.investment_amount}",
                        self.data_source,
                    ],
                }
            )
            params_df.to_excel(writer, sheet_name="回测参数", index=False)

        print(f"\n✅ 回测结果已保存到: fund_backtest_results_{self.fund_code}.xlsx")


def main():
    """主函数"""
    print("=" * 60)
    print("基金定投策略回测系统 (国内数据源版)")
    print("=" * 60)

    while True:
        # 设置回测参数
        fund_code = input("请输入基金代码（如：000001）: ").strip()

        # 默认参数（可修改）
        start_date = "2025-01-01"
        end_date = "2026-01-01"
        investment_amount = 400

        print(f"\n使用默认参数:")
        print(f"  开始日期: {start_date}")
        print(f"  结束日期: {end_date}")
        print(f"  每次定投金额: ¥{investment_amount}")

        change_params = input("\n是否修改参数？(y/n): ").strip().lower()

        if change_params == "y":
            start_date = input("请输入开始日期 (YYYY-MM-DD): ").strip()
            end_date = input("请输入结束日期 (YYYY-MM-DD): ").strip()
            investment_amount = float(input("请输入每次定投金额: ").strip())

        # 选择数据源
        print("\n可选数据源:")
        print("  1. Akshare (推荐，免费)")
        print("  2. Baostock (免费)")
        data_source_choice = input("请选择数据源 (1或2，默认1): ").strip()

        data_source = "akshare" if data_source_choice != "2" else "baostock"

        # 创建回测实例
        backtest = FundBacktest(
            fund_code=fund_code,
            start_date=start_date,
            end_date=end_date,
            investment_amount=investment_amount,
            data_source=data_source,
        )

        # 运行回测
        results = backtest.run_backtest()

        if results:
            print("\n" + "=" * 60)
            print("回测完成！")
            print(f"图表已保存为: fund_dca_backtest_{fund_code}.png")
            print(f"详细数据已保存为: fund_backtest_results_{fund_code}.xlsx")
            print("=" * 60)


if __name__ == "__main__":
    main()

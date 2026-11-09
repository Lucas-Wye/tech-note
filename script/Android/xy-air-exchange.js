
/**
 * 兴业生活 App —— 积分兑换 · 航里兑换（航司及里程数可配置）
 * ------------------------------------------------------------------
 * 运行环境：Auto.js 4.1.x / Auto.js Pro（Android 7.0 以上）
 *
 * 使用前准备：
 *   1. 安装 Auto.js，授予「无障碍服务」权限（脚本首次运行会自动跳转设置）
 *   2. 关闭系统对兴业生活的电池优化 / 后台限制，避免切页面掉帧
 *   3. 已登录兴业生活账号，积分足够兑换 500 里程
 *   4. 建议先手动走一遍流程，核对 CONFIG 里的关键字是否与页面文案一致
 *   5. 在 CONFIG.targetAirline 填写页面显示的航司名，例如「国泰航空」「南方航空」
 *   6. 提前运行并保持手机解锁：启用定时后，脚本会在所配置航司的入口等待当天指定时间
 *
 * 设计思路：
 *   - 全部使用「文本关键字 + 最近可点击父控件」定位，不写死坐标，可跨机型复用
 *   - 每一步都有滑动查找兜底、超时保护和日志输出，失败即停，不会乱点
 *   - 遇到「支付密码 / 交易密码 / 验证码」环节立即停止，交由人工完成
 *   - CONFIG.dryRun = true 时只走到「立即兑换」按钮前，不真正提交
 *
 * 若页面为 H5(WebView) 且完全取不到文本节点：说明该 App 未把节点暴露给无障碍，
 * 需要打开 Auto.js 的「提取 WebView 文本」选项，或改用坐标方案。
 */

"auto";

var CONFIG = {
    // 应用启动：知道包名可填（如 "com.cib.xxx"），留空则按应用名启动
    packageName: "",
    appName: "兴业生活",

    miles: 500,                              // 兑换里程数
    milesInputId: "",                       // 可选：里程输入框的完整资源 ID，填写后优先精确定位
    milesInputKeys: ["兑换里程数", "里程数", "兑换数量"], // 输入框提示或旁边的字段标签

    entrySchedule: {
        enabled: false,                      // false = 不等待，直接进入所配置的航司
        time: "11:00:00"                     // 手机本地时间，HH:mm:ss；当天已过则立即进入
    },

    entryPoints:    ["积分兑换", "积分商城", "积分兑好礼"],
    airlineEntries: ["航里兑换", "里程兑换", "航空里程", "航司里程"],
    targetAirline:  "国泰航空",               // 要兑换的航司名，按页面文字填写，例如「南方航空」

    agreementKeys:  ["我已阅读并同意", "阅读并同意", "同意以下条款"],
    redeemBtnKeys:  ["立即兑换", "确认兑换", "马上兑换"],
    confirmKeys:    ["确定", "确认", "继续兑换"],
    successKeys:    ["兑换成功", "提交成功", "申请成功"],
    failKeys:       ["余额不足", "积分不足", "兑换失败", "库存不足", "已达上限"],
    blockKeys:      ["支付密码", "交易密码", "验证码", "短信验证"],

    stepTimeout:  15000,                     // 单步查找超时(ms)
    shortTimeout: 5000,
    clickGap:     900,                       // 每次点击后的缓冲
    scrollTimes:  3,                         // 找不到时向下滑动的次数
    dryRun:       false                      // true = 只导航，不提交兑换
};

var TAG = "[兴业生活]";

/* ============================ 基础工具 ============================ */

function log(msg) {
    console.log(TAG + " " + msg);
    try { toast(msg); } catch (e) {}
}

function isVisible(w) {
    try {
        if (typeof w.visibleToUser === "function") return w.visibleToUser();
        var b = w.bounds();
        return !!(b && b.width() > 0 && b.height() > 0);
    } catch (e) {
        return false;
    }
}

function isEnabled(w) {
    try { return typeof w.enabled === "function" ? w.enabled() : true; } catch (e) { return true; }
}

function isChecked(w) {
    try { return typeof w.checked === "function" ? w.checked() : false; } catch (e) { return false; }
}

/** 在若干关键字里循环等待，返回第一个可见控件；超时返回 null */
function findTextAny(keys, timeout) {
    timeout = timeout || CONFIG.stepTimeout;
    var end = Date.now() + timeout;
    while (Date.now() < end) {
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            try {
                var list = textContains(k).find();
                for (var j = 0; j < list.length; j++) {
                    if (isVisible(list[j])) return list[j];
                }
                var dlist = descContains(k).find();
                for (var m = 0; m < dlist.length; m++) {
                    if (isVisible(dlist[m])) return dlist[m];
                }
            } catch (e) {}
        }
        sleep(250);
    }
    return null;
}

/** 点击控件：优先点可点击的父控件，否则按坐标点中心 */
function clickWidget(w) {
    if (!w) return false;
    var target = w;
    for (var i = 0; i < 6; i++) {
        try {
            if (target.clickable && target.clickable()) break;
            var p = target.parent();
            if (!p) break;
            target = p;
        } catch (e) { break; }
    }
    try {
        if (target.clickable && target.clickable() && target.click()) return true;
    } catch (e) {}
    try {
        var b = w.bounds();
        if (b && b.width() > 0 && b.height() > 0) {
            return click(b.centerX(), b.centerY());
        }
    } catch (e) {}
    return false;
}

/** 页面上滑（查看下方内容） */
function swipeUp() {
    swipe(device.width / 2, device.height * 0.72, device.width / 2, device.height * 0.35, 600);
    sleep(700);
}

/** 页面下滑（回看上方内容） */
function swipeDown() {
    swipe(device.width / 2, device.height * 0.35, device.width / 2, device.height * 0.72, 600);
    sleep(700);
}

/** 固定为启动当天的目标时间，避免导航耗时跨过整点后误等到第二天。 */
function getEntryTime() {
    if (!CONFIG.entrySchedule.enabled) return null;
    var value = CONFIG.entrySchedule.time;
    var parts = /^(\d{2}):(\d{2}):(\d{2})$/.exec(value);
    if (!parts || Number(parts[1]) > 23 || Number(parts[2]) > 59 || Number(parts[3]) > 59) {
        throw new Error("entrySchedule.time 必须为有效的 HH:mm:ss，例如 11:00:00");
    }
    var target = new Date();
    target.setHours(Number(parts[1]), Number(parts[2]), Number(parts[3]), 0);
    return target.getTime();
}

/** 只等待本次运行的目标时间；最后一秒缩短间隔，不提前点击。 */
function waitForEntry(targetTime) {
    if (targetTime == null) return;
    if (Date.now() >= targetTime) {
        log("已到设定时间，立即进入「" + CONFIG.targetAirline + "」");
        return;
    }
    log("「" + CONFIG.targetAirline + "」入口已找到，等待当天 " + CONFIG.entrySchedule.time + "，请保持手机解锁、停留在当前页面");
    var nextReport = Date.now();
    while (true) {
        var remaining = targetTime - Date.now();
        if (remaining <= 0) break;
        if (Date.now() >= nextReport) {
            console.log(TAG + " 距进入「" + CONFIG.targetAirline + "」还有 " + Math.ceil(remaining / 1000) + " 秒");
            nextReport = Date.now() + 30000;
        }
        sleep(Math.min(remaining, remaining > 1000 ? 500 : 20));
    }
    log("已到设定时间，进入「" + CONFIG.targetAirline + "」");
}

/** 找到并点击；找不到时滑动查找 */
function tapKeys(keys, label, opt) {
    opt = opt || {};
    var w = findTextAny(keys, opt.timeout || CONFIG.shortTimeout);
    if (!w && opt.scroll !== false) {
        log("未直接找到「" + label + "」，滑动查找…");
        for (var s = 0; s < CONFIG.scrollTimes; s++) {
            swipeUp();
            w = findTextAny(keys, 2500);
            if (w) break;
        }
    }
    if (!w) { log("✗ 未找到「" + label + "」"); return false; }
    if (opt.entryTime != null) {
        waitForEntry(opt.entryTime);
        // 长时间等待后原控件可能已失效，重新获取当前页面上的入口。
        w = findTextAny(keys, opt.timeout || CONFIG.shortTimeout);
        if (!w) { log("✗ 等待结束后未找到「" + label + "」，流程停止"); return false; }
    }
    var ok = clickWidget(w);
    log((ok ? "✓ 点击「" : "✗ 点击失败「") + label + "」");
    sleep(opt.gap || CONFIG.clickGap);
    return ok;
}

/** 关闭启动广告、升级提示等弹窗（只在导航前调用，不点"取消"类危险按钮） */
function dismissPopups() {
    var keys = ["跳过", "关闭", "我知道了", "以后再说", "暂不开启"];
    for (var i = 0; i < keys.length; i++) {
        try {
            var list = text(keys[i]).find();
            for (var j = 0; j < list.length; j++) {
                if (isVisible(list[j])) {
                    clickWidget(list[j]);
                    log("关闭弹窗：「" + keys[i] + "」");
                    sleep(600);
                    return true;
                }
            }
        } catch (e) {}
    }
    return false;
}

/* ============================ 业务步骤 ============================ */

function ensureAccessibility() {
    try {
        if (typeof auto !== "undefined" && auto.waitFor) auto.waitFor();
        log("无障碍服务已就绪");
    } catch (e) {
        log("请手动开启无障碍服务后重新运行");
    }
}

function openApp() {
    log("启动「" + CONFIG.appName + "」…");
    var ok = false;
    try {
        ok = CONFIG.packageName ? app.launchPackage(CONFIG.packageName) : app.launchApp(CONFIG.appName);
    } catch (e) {
        log("启动异常：" + e);
    }
    if (!ok) {
        log("未能启动应用，请确认已安装「" + CONFIG.appName + "」或在 CONFIG.packageName 填写包名");
    }
    sleep(4000);

    // 等待首页特征出现
    for (var i = 0; i < 10; i++) {
        if (findTextAny(["首页", "我的", "生活", "积分"], 1500)) break;
        sleep(800);
    }
    dismissPopups();
}

function gotoPointsExchange() {
    log("① 进入【积分兑换】");
    if (!tapKeys(CONFIG.entryPoints, "积分兑换")) {
        // 兜底：先进"我的"，再找积分入口
        tapKeys(["我的"], "我的", { scroll: false });
        sleep(1200);
        if (!tapKeys(CONFIG.entryPoints, "积分兑换")) return false;
    }
    sleep(1500);
    return true;
}

function gotoAirlineExchange() {
    log("② 进入【航里兑换】");
    if (!tapKeys(CONFIG.airlineEntries, "航里兑换")) return false;
    sleep(1500);
    return true;
}

function chooseAirline(entryTime) {
    log("③ 选择【" + CONFIG.targetAirline + "】");
    if (!tapKeys([CONFIG.targetAirline], CONFIG.targetAirline, { entryTime: entryTime })) return false;
    sleep(1500);
    return true;
}

function hideKeyboard() {
    // 输入完成后收起键盘，避免遮挡底部按钮
    try {
        back();
        sleep(800);
    } catch (e) {}
}

function containsMilesKey(value) {
    value = String(value || "");
    for (var i = 0; i < CONFIG.milesInputKeys.length; i++) {
        if (CONFIG.milesInputKeys[i] && value.indexOf(CONFIG.milesInputKeys[i]) >= 0) return true;
    }
    return false;
}

/** 判断输入框自身的文本、描述或提示是否明确表示兑换里程。 */
function isMilesInput(w) {
    try { if (containsMilesKey(w.text())) return true; } catch (e) {}
    try { if (containsMilesKey(w.desc())) return true; } catch (e) {}
    try { if (typeof w.hint === "function" && containsMilesKey(w.hint())) return true; } catch (e) {}
    return false;
}

function sameWidget(a, b) {
    try { return a === b || a.equals(b); } catch (e) { return a === b; }
}

/** 标签与输入框必须在同一行，或标签紧贴输入框上方。 */
function isNearMilesLabel(label, input) {
    try {
        var a = label.bounds(), b = input.bounds();
        var height = Math.max(a.height(), b.height());
        var sameRow = Math.abs(a.centerY() - b.centerY()) <= Math.min(a.height(), b.height()) / 2;
        var onRight = b.left >= a.right - 8 && b.left - a.right <= device.width * 0.4;
        var below = b.top >= a.bottom - 8 && b.top - a.bottom <= height;
        var aligned = Math.min(a.right, b.right) > Math.max(a.left, b.left);
        return (sameRow && onRight) || (below && aligned);
    } catch (e) { return false; }
}

/** 优先精确 ID / 输入框自身提示，其次使用标签位置；候选不唯一时不猜。 */
function findMilesInput() {
    var end = Date.now() + CONFIG.stepTimeout;
    while (Date.now() < end) {
        var inputs = [], matches = [];
        try {
            var all = className("android.widget.EditText").find();
            for (var i = 0; i < all.length; i++) {
                if (isVisible(all[i]) && isEnabled(all[i])) inputs.push(all[i]);
            }
        } catch (e) {}

        for (var j = 0; j < inputs.length; j++) {
            if (CONFIG.milesInputId) {
                try { if (inputs[j].id() === CONFIG.milesInputId) matches.push(inputs[j]); } catch (e) {}
            } else if (isMilesInput(inputs[j])) {
                matches.push(inputs[j]);
            }
        }

        if (!CONFIG.milesInputId && matches.length === 0) {
            var labels = [];
            for (var k = 0; k < CONFIG.milesInputKeys.length; k++) {
                var key = CONFIG.milesInputKeys[k];
                if (!key) continue;
                try {
                    var texts = textContains(key).find();
                    for (var t = 0; t < texts.length; t++) {
                        if (isVisible(texts[t])) labels.push(texts[t]);
                    }
                    var descs = descContains(key).find();
                    for (var d = 0; d < descs.length; d++) {
                        if (isVisible(descs[d])) labels.push(descs[d]);
                    }
                } catch (e) {}
            }
            for (var n = 0; n < inputs.length; n++) {
                for (var l = 0; l < labels.length; l++) {
                    if (!sameWidget(labels[l], inputs[n]) && isNearMilesLabel(labels[l], inputs[n])) {
                        matches.push(inputs[n]);
                        break;
                    }
                }
            }
        }
        if (matches.length === 1) return matches[0];
        if (matches.length > 1) {
            log("✗ 识别到多个里程输入框，请配置 milesInputId 精确定位");
            return null;
        }
        sleep(250);
    }
    return null;
}

function inputMiles() {
    log("④ 输入兑换里程：" + CONFIG.miles);
    var et = findMilesInput();
    if (!et) {
        log("✗ 无法明确定位兑换里程输入框，已停止；请核对 milesInputKeys 或配置 milesInputId");
        return false;
    }

    try {
        if (et.setText(String(CONFIG.miles)) === false) {
            log("✗ 里程输入框拒绝写入");
            return false;
        }
        sleep(700);
        log("✓ 已输入 " + CONFIG.miles);
    } catch (e) {
        log("✗ 输入失败：" + e);
        return false;
    }

    hideKeyboard();
    if (!findTextAny(CONFIG.redeemBtnKeys, 3000)) {
        log("提示：收起键盘后仍未看到兑换按钮，可能被遮挡，稍后重试");
    }
    return true;
}

function agreeTerms() {
    log("⑤ 勾选「我已阅读并同意以下条款」");

    var boxes = [];
    try { boxes = className("android.widget.CheckBox").find(); } catch (e) {}

    var chosen = null, alreadyChecked = false;
    for (var i = 0; i < boxes.length; i++) {
        if (!isVisible(boxes[i])) continue;
        if (isChecked(boxes[i])) { alreadyChecked = true; chosen = boxes[i]; break; }
        if (!chosen) chosen = boxes[i];
    }

    if (alreadyChecked) {
        log("✓ 条款已处于勾选状态，无需重复点击");
        return true;
    }
    if (chosen) {
        clickWidget(chosen);
        sleep(600);
        log("✓ 已点击复选框控件");
        return true;
    }

    // 无 CheckBox 控件（常见于 H5）：点条款文字左侧的勾选框
    var t = findTextAny(CONFIG.agreementKeys, CONFIG.shortTimeout);
    if (!t) {
        log("✗ 未找到条款文字，无法勾选");
        return false;
    }
    var b = t.bounds();
    var off = Math.max(28, Math.round(device.width * 0.035));
    var clicked = click(b.left - off, b.centerY());
    if (!clicked) {
        // 再向左多试一点，应对勾选框与文字间距较大的页面
        clicked = click(b.left - off * 2, b.centerY());
    }
    sleep(600);
    log(clicked ? "✓ 已点击条款前的勾选框（坐标兜底）" : "✗ 勾选失败，请手动勾选");
    return clicked;
}

function handleConfirm() {
    // 处理二次确认弹窗；遇到密码/验证码立即停止
    for (var i = 0; i < 6; i++) {
        var block = findTextAny(CONFIG.blockKeys, 1000);
        if (block) {
            log("⛔ 出现密码/验证码环节，脚本停止，请手动完成");
            return "blocked";
        }
        var btn = findTextAny(CONFIG.confirmKeys, 2000);
        if (btn) {
            clickWidget(btn);
            log("✓ 已点击二次确认按钮");
            sleep(1200);
            return "confirmed";
        }
        sleep(500);
    }
    return "none";
}

function watchResult() {
    for (var i = 0; i < 20; i++) {
        var ok = findTextAny(CONFIG.successKeys, 1000);
        if (ok) {
            log("✅ 兑换成功，页面提示：" + safeText(ok));
            return "success";
        }
        var bad = findTextAny(CONFIG.failKeys, 1000);
        if (bad) {
            log("❌ 兑换未成功，页面提示：" + safeText(bad));
            return "failed";
        }
        var block = findTextAny(CONFIG.blockKeys, 500);
        if (block) {
            log("⛔ 出现密码/验证码环节，脚本停止，请手动完成");
            return "blocked";
        }
        sleep(800);
    }
    log("未捕获到明确结果，请人工确认页面状态");
    return "unknown";
}

function safeText(w) {
    try { return w.text() || ""; } catch (e) { return ""; }
}

function tapRedeem() {
    log("⑥ 点击【立即兑换】");
    var w = findTextAny(CONFIG.redeemBtnKeys, CONFIG.stepTimeout);
    if (!w) {
        log("✗ 未找到「立即兑换」按钮");
        return false;
    }
    if (!isEnabled(w)) {
        log("提示：按钮可能为置灰状态（未满足兑换条件），仍尝试点击");
    }

    if (CONFIG.dryRun) {
        log("dryRun = true，已停在提交前，未实际点击「立即兑换」");
        return true;
    }

    clickWidget(w);
    log("✓ 已点击「立即兑换」");
    sleep(1500);

    var confirmState = handleConfirm();
    var result = watchResult();

    if (confirmState === "blocked" || result === "blocked") return false;
    return result !== "failed";
}

/* ============================ 主流程 ============================ */

function main() {
    try { console.show(); } catch (e) {}

    if (typeof CONFIG.targetAirline !== "string" || !CONFIG.targetAirline.trim()) {
        throw new Error("targetAirline 必须填写页面显示的航司名，例如：国泰航空");
    }
    CONFIG.targetAirline = CONFIG.targetAirline.trim();
    log("====== 开始执行：兴业生活 积分兑换 · " + CONFIG.targetAirline + " " + CONFIG.miles + " 里程 ======");

    // 配置错误时在启动 App 前停止；目标日期取脚本开始运行当天。
    var entryTime = getEntryTime();
    ensureAccessibility();
    openApp();
    if (!gotoPointsExchange() || !gotoAirlineExchange()) {
        log("流程中止：未能进入航里兑换页面");
        return;
    }
    if (!chooseAirline(entryTime)) {
        log("流程中止：未能进入「" + CONFIG.targetAirline + "」页面");
        return;
    }

    if (!inputMiles()) {
        log("流程中止：里程输入失败");
        return;
    }
    if (!agreeTerms()) {
        log("流程中止：条款勾选失败");
        return;
    }
    tapRedeem();

    log("====== 执行结束 ======");
}

var keepingScreenOn = false;
try {
    if (CONFIG.entrySchedule.enabled) {
        try {
            device.keepScreenOn();
            keepingScreenOn = true;
        } catch (e) { log("无法保持屏幕常亮，请手动保持手机解锁"); }
    }
    main();
} catch (e) {
    log("流程中止：" + e);
} finally {
    if (keepingScreenOn) {
        try { device.cancelKeepingAwake(); } catch (e) {}
    }
}
exit();

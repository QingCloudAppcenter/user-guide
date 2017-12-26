<script type="text/javascript">
(function () {
    var current_path = window.location.pathname
    var path_language = (current_path.indexOf("en-US") > 0) ? "en" : "zh"
    var path_to = function (lang) {
        window.sessionStorage.setItem("language", lang)
        if (lang == path_language) {
            return
        }
        var dst_path = ""
        if (current_path.indexOf("-en-US.html") > 0) {
            if (current_path.indexOf("README-en-US.html") > 0) {
                dst_path = current_path.replace("README-en-US.html", "")
            } else {
                dst_path = current_path.replace("-en-US", "")
            }
        } else {
            if (current_path.indexOf(".html") > 0) {
                dst_path = current_path.replace(".html", "-en-US.html")
            } else {
                dst_path = current_path + "README-en-US.html"
            }
        }
        window.location.pathname = dst_path
    }
    var setting_language = window.sessionStorage.getItem("language")
    var browser_language = navigator.language || navigator.userLanguage
    browser_language = (browser_language.indexOf("zh") == 0) ? "zh" : "en"
    if (!setting_language) {
        return path_to(browser_language)
    }
    if (setting_language != path_language) {
        window.sessionStorage.setItem("language", path_language)
    }
})()
</script>
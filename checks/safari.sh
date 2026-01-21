#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#safari
# Source: kristovatlas/osx-config-check (CHECK #49-54, #56, #59, #61-62, #68-74)

# Retrieve values
fraud_warning=$(
    defaults read com.apple.Safari WarnAboutFraudulentWebsites 2>/dev/null
)
do_not_track=$(
    defaults read com.apple.Safari SendDoNotTrackHTTPHeader 2>/dev/null
)
autofill_cards=$(
    defaults read com.apple.Safari AutoFillCreditCardData 2>/dev/null
)
autofill_passwords=$(
    defaults read com.apple.Safari AutoFillPasswords 2>/dev/null
)
block_popups=$(
    defaults read com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically 2>/dev/null
)
auto_open=$(
    defaults read com.apple.Safari AutoOpenSafeDownloads 2>/dev/null
)
block_cookies=$(
    defaults read com.apple.Safari BlockStoragePolicy 2>/dev/null
)
webgl=$(
    defaults read com.apple.Safari WebKitWebGLEnabled 2>/dev/null
)
plugins=$(
    defaults read com.apple.Safari WebKitPluginsEnabled 2>/dev/null
)
sha1_insecure=$(
    defaults read com.apple.Safari TreatSHA1CertificatesAsInsecure 2>/dev/null
)
preload=$(
    defaults read com.apple.Safari PreloadTopHit 2>/dev/null
)
suppress_suggestions=$(
    defaults read com.apple.Safari SuppressSearchSuggestions 2>/dev/null
)
show_full_url=$(
    defaults read com.apple.Safari ShowFullURLInSmartSearchField 2>/dev/null
)

# Apply defaults
fraud_warning=${fraud_warning:-1}
do_not_track=${do_not_track:-0}
autofill_cards=${autofill_cards:-0}
autofill_passwords=${autofill_passwords:-0}
block_popups=${block_popups:-0}
auto_open=${auto_open:-1}
block_cookies=${block_cookies:-0}
webgl=${webgl:-1}
plugins=${plugins:-1}
sha1_insecure=${sha1_insecure:-0}
preload=${preload:-1}
suppress_suggestions=${suppress_suggestions:-0}
show_full_url=${show_full_url:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_fraud_warning=$WARN
pass_do_not_track=$INFO
pass_autofill_credit_cards=$INFO
pass_autofill_passwords=$INFO
pass_block_popups=$INFO
pass_auto_open_downloads=$INFO
pass_block_cookies=$INFO
pass_webgl=$INFO
pass_plugins=$INFO
pass_sha1_insecure=$INFO
pass_preload_top_hit=$INFO
pass_search_suggestions=$INFO
pass_show_full_url=$INFO

[[ "$fraud_warning" == "1" ]]        && pass_fraud_warning=$OK
[[ "$do_not_track" == "1" ]]         && pass_do_not_track=$OK
[[ "$autofill_cards" == "0" ]]       && pass_autofill_credit_cards=$OK
[[ "$autofill_passwords" == "0" ]]   && pass_autofill_passwords=$OK
[[ "$block_popups" == "0" ]]         && pass_block_popups=$OK
[[ "$auto_open" == "0" ]]            && pass_auto_open_downloads=$OK
[[ "$block_cookies" == "2" ]]        && pass_block_cookies=$OK
[[ "$webgl" == "0" ]]                && pass_webgl=$OK
[[ "$plugins" == "0" ]]              && pass_plugins=$OK
[[ "$sha1_insecure" == "1" ]]        && pass_sha1_insecure=$OK
[[ "$preload" == "0" ]]              && pass_preload_top_hit=$OK
[[ "$suppress_suggestions" == "1" ]] && pass_search_suggestions=$OK
[[ "$show_full_url" == "1" ]]        && pass_show_full_url=$OK

# Output
echo "pass_fraud_warning:$pass_fraud_warning"
echo "pass_do_not_track:$pass_do_not_track"
echo "pass_autofill_credit_cards:$pass_autofill_credit_cards"
echo "pass_autofill_passwords:$pass_autofill_passwords"
echo "pass_block_popups:$pass_block_popups"
echo "pass_auto_open_downloads:$pass_auto_open_downloads"
echo "pass_block_cookies:$pass_block_cookies"
echo "pass_webgl:$pass_webgl"
echo "pass_plugins:$pass_plugins"
echo "pass_sha1_insecure:$pass_sha1_insecure"
echo "pass_preload_top_hit:$pass_preload_top_hit"
echo "pass_search_suggestions:$pass_search_suggestions"
echo "pass_show_full_url:$pass_show_full_url"

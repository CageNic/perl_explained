###############################
#### Matching alternatives ####
###############################

# The vertical bar character (|) is used to denote alternate matches. A regular expression, such as:
/regular expression|regex/
# will match either the string “regular expression” or the string “regex”. Parentheses (( and )) can be used to group strings, so while
/regexes are cool|rubbish/
# matches the strings “regexes are cool” or “rubbish”
/regexes are (cool|rubbish)/
# matches “regexes are cool” or “regexes are rubbish”



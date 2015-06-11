cd ${JSON_DIR}
replace "Debian GNU/Linux" "Debian GNU_Linux" -- *-organizations*
find . -name "*-organizations.json" | awk -F 'organizations' '{print "cp " $0 " " $1 "companies.json"}' | sh
replace '"organizations": ' '"companies": ' -- *.json
cp scr-organizations-quarters.json scr-companies-quarters.json
cp scr-organizations-all.json scr-companies-all.json
cp scm-organizations-commits-summary.json scm-companies-commits-summary.json

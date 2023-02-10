Describe "mommy"
    config="./config"
    mommy="../../main/sh/mommy"

    clean_config() { rm -f "$config"; }
    After "clean_config"

    Describe "command-line options"
        Describe "help information"
            It "outputs help information using -h"
                When run "$mommy" -h
                The word 1 of output should equal "mommy(1)"
                The status should be success
            End

            It "outputs help information using --help"
                When run "$mommy" --help
                The word 1 of output should equal "mommy(1)"
                The status should be success
            End

            It "outputs help information even when -h is not the first option"
                When run "$mommy" -c "./a_file" -h
                The word 1 of output should equal "mommy(1)"
                The status should be success
            End
        End

        Describe "custom configuration file"
            It "ignores an invalid path"
                When run "$mommy" -c "./does_not_exist" true
                The output should not equal ""
                The status should be success
            End

            It "uses the configuration from the given file"
                echo "MOMMY_COMPLIMENTS='apply news';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "apply news"
                The status should be success
            End
        End

        Describe "command"
            It "writes a compliment to stdout if the command returns 0 status"
                echo "MOMMY_COMPLIMENTS='purpose wall';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "purpose wall"
                The status should be success
            End

            It "writes an encouragement to stderr if the command returns non-0 status"
                echo "MOMMY_ENCOURAGEMENTS='razor woolen';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" false
                The error should equal "razor woolen"
                The status should be failure
            End

            It "returns the non-0 status of the command"
                When run "$mommy" return 4
                The error should not equal ""
                The status should equal 4
            End

            It "passes all arguments to the command"
                echo "MOMMY_COMPLIMENTS='disagree mean';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" echo a b c
                The line 1 of output should equal "a b c"
                The line 2 of output should equal "disagree mean"
                The status should be success
            End
        End

        Describe "eval"
            It "writes a compliment to stdout if the evaluated command returns 0 status"
                echo "MOMMY_COMPLIMENTS='bold accord';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "true"
                The output should equal "bold accord"
                The status should be success
            End

            It "writes an encouragement to stderr if the evaluated command returns non-0 status"
                echo "MOMMY_ENCOURAGEMENTS='head log';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "false"
                The error should equal "head log"
                The status should be failure
            End

            It "returns the non-0 status of the evaluated command"
                When run "$mommy" -e "return 4"
                The error should not equal ""
                The status should equal 4
            End

            It "passes all arguments to the command"
                echo "MOMMY_COMPLIMENTS='desire bread';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "echo a b c"
                The line 1 of output should equal "a b c"
                The line 2 of output should equal "desire bread"
                The status should be success
            End

            It "considers the command a success if all parts succeed"
                echo "MOMMY_COMPLIMENTS='milk literary';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "echo 'a/b/c' | cut -d '/' -f 1"
                The line 2 of output should equal "milk literary"
                The status should be success
            End

            It "considers the command a success if any part fails"
                echo "MOMMY_ENCOURAGEMENTS='bear cupboard';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "echo 'a/b/c' | cut -d '/' -f 0"
                The line 3 of error should equal "bear cupboard"
                The status should be failure
            End
        End

        Describe "status"
            It "writes a compliment to stdout if the status is 0"
                echo "MOMMY_COMPLIMENTS='station top';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -s 0
                The output should equal "station top"
                The status should be success
            End

            It "writes an encouragement to stderr if the status is non-0"
                echo "MOMMY_ENCOURAGEMENTS='mend journey';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -s 1
                The error should equal "mend journey"
                The status should be failure
            End

            It "returns the given non-0 status"
                When run "$mommy" -s 167
                The error should not equal ""
                The status should equal 167
            End
        End
    End

    Describe "configuration"
        Describe "template variables"
            It "replaces %%SWEETIE%%"
                echo "MOMMY_COMPLIMENTS='>%%SWEETIE%%<';MOMMY_SUFFIX='';MOMMY_SWEETIE='attempt'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal ">attempt<"
                The status should be success
            End

            It "replaces %%THEIR%%"
                echo "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_SUFFIX='';MOMMY_THEIR='respect'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal ">respect<"
                The status should be success
            End

            It "replaces %%CAREGIVER%%"
                echo "MOMMY_COMPLIMENTS='>%%CAREGIVER%%<';MOMMY_SUFFIX='';MOMMY_CAREGIVER='help'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal ">help<"
                The status should be success
            End

            It "appends the suffix"
                echo "MOMMY_COMPLIMENTS='>';MOMMY_SUFFIX='respect'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal ">respect"
                The status should be success
            End

            It "chooses a random pronoun"
                # Runs mommy several times and checks if output is different at least once.
                # Probability of 1/(26^4)=1/456976 to fail even if code is correct.

                pronouns="a/b/c/d/e/f/g/h/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
                echo "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_SUFFIX='';MOMMY_THEIR='$pronouns'" > "$config"

                output1=$("$mommy" -c "$config" true)
                output2=$("$mommy" -c "$config" true)
                output3=$("$mommy" -c "$config" true)
                output4=$("$mommy" -c "$config" true)
                output5=$("$mommy" -c "$config" true)

                [ "$output1" != "$output2" ] || [ "$output1" != "$output3" ] \
                                             || [ "$output1" != "$output4" ] \
                                             || [ "$output1" != "$output5" ]
                is_different="$?"

                When call test "$is_different" -eq 0
                The status should be success
            End

            It "chooses the empty string if no pronouns are set"
                echo "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_SUFFIX='';MOMMY_THEIR=''" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "><"
                The status should be success
            End
        End

        Describe "capitalization"
            It "changes to the first character to lowercase if configured to 0"
                echo "MOMMY_COMPLIMENTS='Alive station';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='0'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "alive station"
                The status should be success
            End

            It "changes to the first character to uppercase if configured to 1"
                echo "MOMMY_COMPLIMENTS='inquiry speech';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='1'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "Inquiry speech"
                The status should be success
            End

            It "uses the template's original capitalization if configured to the empty string"
                echo "MOMMY_COMPLIMENTS='Medicine frighten';MOMMY_SUFFIX='';MOMMY_CAPITALIZE=" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "Medicine frighten"
                The status should be success
            End

            It "uses the template's original capitalization if configured to anything else"
                echo "MOMMY_COMPLIMENTS='Belong shore';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='2'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "Belong shore"
                The status should be success
            End

            It "changes capitalization on all lines"
                echo "MOMMY_COMPLIMENTS='luck
fashion';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='1'" > "$config"

                When run "$mommy" -c "$config" true
                The output should equal "Luck
Fashion"
                The status should be success
            End
        End

        Describe "compliments/encouragements"
            Describe "selection"
                It "chooses from 'MOMMY_COMPLIMENTS'"
                    echo "MOMMY_COMPLIMENTS='spill drown';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "spill drown"
                    The status should be success
                End

                It "chooses from 'MOMMY_COMPLIMENTS_EXTRA'"
                    echo "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA='bill lump';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "bill lump"
                    The status should be success
                End

                It "chooses a multiline compliment"
                    echo "MOMMY_COMPLIMENTS='loud
    bank/loud
    bank';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "loud
    bank"
                    The status should be success
                End

                It "outputs nothing if no compliments are set"
                    echo "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA='';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal ""
                    The status should be success
                End
            End

            Describe "slashes"
                It "inserts a virtual / in between 'MOMMY_COMPLIMENTS' and 'MOMMY_COMPLIMENTS_EXTRA'"
                    echo "MOMMY_COMPLIMENTS='curse';MOMMY_COMPLIMENTS_EXTRA='dear';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should not equal "curse dear"
                    The status should be success
                End

                It "ignores leading slashes"
                    # Probability of ~1/30 to pass even if code is buggy

                    echo "MOMMY_COMPLIMENTS='/////////////////////////////boy only';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "boy only"
                    The status should be success
                End

                It "ignores trailing slashes"
                    # Probability of ~1/30 to pass even if code is buggy

                    echo "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA='salt staff/////////////////////////////';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "salt staff"
                    The status should be success
                End

                It "ignores slashes in the middle"
                    # Probability of ~1/30 to pass even if code is buggy

                    echo "MOMMY_COMPLIMENTS='end spring/////////////////////////////end spring';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "end spring"
                    The status should be success
                End

                It "ignores slashes in between 'MOMMY_COMPLIMENTS' and 'MOMMY_COMPLIMENTS_EXTRA'"
                    # Probability of ~1/30 to pass even if code is buggy

                    echo "MOMMY_COMPLIMENTS='attempt cheap///////////////';MOMMY_COMPLIMENTS_EXTRA='//////////////attempt cheap';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "attempt cheap"
                    The status should be success
                End
            End

            Describe "newlines and whitespace"
                It "removes leading newlines"
                    echo "MOMMY_COMPLIMENTS='
quick elastic';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "quick elastic"
                    The status should be success
                End

                It "removes trailing newlines"
                    echo "MOMMY_COMPLIMENTS='happy airplane
';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "happy airplane"
                    The status should be success
                End

                It "retains newlines inside a compliment"
                    echo "MOMMY_COMPLIMENTS='mineral
forward';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "mineral
forward"
                    The status should be success
                End

                It "retains leading whitespace"
                    echo "MOMMY_COMPLIMENTS=' rake fix';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal " rake fix"
                    The status should be success
                End

                It "retains trailing whitespace"
                    echo "MOMMY_COMPLIMENTS='read wealth ';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "read wealth "
                    The status should be success
                End
            End

            Describe "comments"
                It "ignores lines starting with '#'"
                    echo "MOMMY_COMPLIMENTS='weaken
#egg
can';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "weaken
can"
                    The status should be success
                End

                It "does not ignore lines starting with ' #'"
                    echo "MOMMY_COMPLIMENTS='dish
 #seat
absence';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "dish
 #seat
absence"
                    The status should be success
                End

                It "does not ignore lines with a '#' not at the start"
                    echo "MOMMY_COMPLIMENTS='speed
 lo#ud
home';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "speed
 lo#ud
home"
                    The status should be success
                End

                It "ignores the '/' in a comment line"
                    echo "MOMMY_COMPLIMENTS='figure
#penny/some
wear';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "figure
wear"
                    The status should be success
                End
            End

            Describe "toggling"
                It "outputs nothing if a command passes but compliments are disabled"
                    echo "MOMMY_COMPLIMENTS_ENABLED='0';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal ""
                    The status should be success
                End

                It "outputs nothing if a command fails but encouragements are disabled"
                    echo "MOMMY_ENCOURAGEMENTS_ENABLED='0';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" false
                    The output should equal ""
                    The status should be failure
                End
            End

            Describe "forbidden words"
                It "outputs the compliment that does not contain the forbidden word"
                    echo "MOMMY_COMPLIMENTS='mother search/fierce along';MOMMY_FORBIDDEN_WORDS='search';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "fierce along"
                    The status should be success
                End

                It "outputs the only compliment that does not contain a forbidden word"
                    echo "MOMMY_COMPLIMENTS='after boundary/failure school/instant delay';MOMMY_FORBIDDEN_WORDS='instant/boundary';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The output should equal "failure school"
                    The status should be success
                End
            End
        End
    End
End

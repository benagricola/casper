emitTest = () =>
            socket.emit 'test', 
            uid: uuid.v4()
            ## This might be better as a set of objects with names, for verbosity
            steps: [
                [ "start", "http://www.hfmweek.coxm" ]
                [ "element-exists", "li.login > span", "Checking for existence of login area" ]
                [ "click", "li.login > span" ]
                [ "wait-for-element-visible",".login .area"  ]
                [ "element-visible", "#log_in_out_button","Checking for login button visibility" ]
                [ "element-exists", "#log_in_out_button", "Checking for existence of login button" ]
                [ "fill-form",".login .area form", 
                    SQ_LOGIN_USERNAME: 'selenium_user' 
                    SQ_LOGIN_PASSWORD: '2=:U8:!zD;4{"*+' 
                , false ]
                #[ "capture" ]
                [ "click", "#log_in_out_button" ]
                [ "wait-for-text", "You are currently logged in as" ]
                [ "element-has-text", "li.login > span", "Log out", "Checking that login button is now log out" ]
            ]

        emitTest()
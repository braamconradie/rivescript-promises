TestCase = require("./test-base")

################################################################################
# BEGIN Block Tests
################################################################################

exports.test_no_begin_block = (test) ->
    bot = new TestCase(test, """
        + hello bot
        - Hello human.
    """)
    bot.reply("Hello bot", "Hello human.")
    test.done()

exports.test_simple_begin_block = (test) ->
    bot = new TestCase(test, """
        > begin
            + request
            - {ok}
        < begin

        + hello bot
        - Hello human.
    """)
    bot.reply("Hello bot.", "Hello human.")
    test.done()

exports.test_blocked_begin_block = (test) ->
    bot = new TestCase(test, """
        > begin
            + request
            - Nope.
        < begin

        + hello bot
        - Hello human.
    """)
    bot.reply("Hello bot.", "Nope.")
    test.done()

exports.test_conditional_begin_block = (test) ->
    bot = new TestCase(test, """
        > begin
            + request
            * <get met> == undefined => <set met=true>{ok}
            * <get name> != undefined => <get name>: {ok}
            - {ok}
        < begin

        + hello bot
        - Hello human.

        + my name is *
        - <set name=<formal>>Hello, <get name>.
    """)
    bot.reply("Hello bot.", "Hello human.")
    bot.uservar("met", "true")
    bot.uservar("name", "undefined")
    bot.reply("My name is bob", "Hello, Bob.")
    bot.uservar("name", "Bob")
    bot.reply("Hello Bot", "Bob: Hello human.")
    test.done()

################################################################################
#  Bot Variable Tests
################################################################################

exports.test_bot_variables = (test) ->
     bot = new TestCase(test, """
        ! var name = Aiden
        ! var age = 5

        + what is your name
        - My name is <bot name>.

        + how old are you
        - I am <bot age>.

        + what are you
        - I'm <bot gender>.

        + happy birthday
        - <bot age=6>Thanks!
     """)
     bot.reply("What is your name?", "My name is Aiden.")
     bot.reply("How old are you?", "I am 5.")
     bot.reply("What are you?", "I'm undefined.")
     bot.reply("Happy birthday!", "Thanks!")
     bot.reply("How old are you?", "I am 6.")
     test.done()

exports.test_global_variables = (test) ->
    bot = new TestCase(test, """
        ! global debug = false

        + debug mode
        - Debug mode is: <env debug>

        + set debug mode *
        - <env debug=<star>>Switched to <star>.
    """)
    bot.reply("Debug mode.", "Debug mode is: false")
    bot.reply("Set debug mode true", "Switched to true.")
    bot.reply("Debug mode?", "Debug mode is: true")
    test.done()

################################################################################
#  Substitution Tests
################################################################################

 exports.test_substitutions = (test) ->
     bot = new TestCase(test, """
        + whats up
        - nm.

        + what is up
        - Not much.
     """)
     bot.reply("whats up", "nm.")
     bot.reply("what's up?", "nm.")
     bot.reply("what is up?", "Not much.")

     bot.extend("""
        ! sub whats  = what is
        ! sub what's = what is
     """)
     bot.reply("whats up", "Not much.")
     bot.reply("what's up?", "Not much.")
     bot.reply("What is up?", "Not much.")
     test.done()

exports.test_person_substitutions = (test) ->
    bot = new TestCase(test, """
        + say *
        - <person>
    """)
    bot.reply("say I am cool", "i am cool")
    bot.reply("say You are dumb", "you are dumb")

    bot.extend("""
        ! person i am    = you are
        ! person you are = I am
    """)
    bot.reply("say I am cool", "you are cool")
    bot.reply("say You are dumb", "I am dumb")
    test.done()

################################################################################
#  Trigger Tests
################################################################################

exports.test_atomic_triggers = (test) ->
    bot = new TestCase(test, """
        + hello bot
        - Hello human.

        + what are you
        - I am a RiveScript bot.
    """)
    bot.reply("Hello bot", "Hello human.")
    bot.reply("What are you?", "I am a RiveScript bot.")
    test.done()

exports.test_wildcard_triggers = (test) ->
    bot = new TestCase(test, """
        + my name is *
        - Nice to meet you, <star>.

        + * told me to say *
        - Why did <star1> tell you to say <star2>?

        + i am # years old
        - A lot of people are <star>.

        + i am _ years old
        - Say that with numbers.

        + i am * years old
        - Say that with fewer words.
    """)
    bot.reply("my name is Bob", "Nice to meet you, bob.")
    bot.reply("bob told me to say hi", "Why did bob tell you to say hi?")
    bot.reply("i am 5 years old", "A lot of people are 5.")
    bot.reply("i am five years old", "Say that with numbers.")
    bot.reply("i am twenty five years old", "Say that with fewer words.")
    test.done()

exports.test_alternatives_and_optionals = (test) ->
    bot = new TestCase(test, """
        + what (are|is) you
        - I am a robot.

        + what is your (home|office|cell) [phone] number
        - It is 555-1234.

        + [please|can you] ask me a question
        - Why is the sky blue?

        + (aa|bb|cc) [bogus]
        - Matched.

        + (yo|hi) [computer|bot] *
        - Matched.
    """)
    bot.reply("What are you?", "I am a robot.")
    bot.reply("What is you?", "I am a robot.")

    bot.reply("What is your home phone number?", "It is 555-1234.")
    bot.reply("What is your home number?", "It is 555-1234.")
    bot.reply("What is your cell phone number?", "It is 555-1234.")
    bot.reply("What is your office number?", "It is 555-1234.")

    bot.reply("Can you ask me a question?", "Why is the sky blue?")
    bot.reply("Please ask me a question?", "Why is the sky blue?")
    bot.reply("Ask me a question.", "Why is the sky blue?")

    bot.reply("aa", "Matched.")
    bot.reply("bb", "Matched.")
    bot.reply("aa bogus", "Matched.")
    bot.reply("aabogus", "ERR: No Reply Matched")
    bot.reply("bogus", "ERR: No Reply Matched")

    bot.reply("hi Aiden", "Matched.")
    bot.reply("hi bot how are you?", "Matched.")
    bot.reply("yo computer what time is it?", "Matched.")
    bot.reply("yoghurt is yummy", "ERR: No Reply Matched")
    bot.reply("hide and seek is fun", "ERR: No Reply Matched")
    bot.reply("hip hip hurrah", "ERR: No Reply Matched")
    test.done()

exports.test_trigger_arrays = (test) ->
    bot = new TestCase(test, """
        ! array colors = red blue green yellow white
          ^ dark blue|light blue

        + what color is my (@colors) *
        - Your <star2> is <star1>.

        + what color was * (@colors) *
        - It was <star2>.

        + i have a @colors *
        - Tell me more about your <star>.
    """)
    bot.reply("What color is my red shirt?", "Your shirt is red.")
    bot.reply("What color is my blue car?", "Your car is blue.")
    bot.reply("What color is my pink house?", "ERR: No Reply Matched")
    bot.reply("What color is my dark blue jacket?", "Your jacket is dark blue.")
    bot.reply("What color was Napoleoan's white horse?", "It was white.")
    bot.reply("What color was my red shirt?", "It was red.")
    bot.reply("I have a blue car.", "Tell me more about your car.")
    bot.reply("I have a cyan car.", "ERR: No Reply Matched")
    test.done()

exports.test_weighted_triggers = (test) ->
    bot = new TestCase(test, """
        + * or something{weight=10}
        - Or something. <@>

        + can you run a google search for *
        - Sure!

        + hello *{weight=20}
        - Hi there!
    """)
    bot.reply("Hello robot.", "Hi there!")
    bot.reply("Hello or something.", "Hi there!")
    bot.reply("Can you run a Google search for Node", "Sure!")
    bot.reply("Can you run a Google search for Node or something", "Or something. Sure!")
    test.done()

################################################################################
#  Reply Tests
################################################################################

exports.test_previous = (test) ->
    bot = new TestCase(test, """
        ! sub who's  = who is
        ! sub it's   = it is
        ! sub didn't = did not

        + knock knock
        - Who's there?

        + *
        % who is there
        - <sentence> who?

        + *
        % * who
        - Haha! <sentence>!

        + *
        - I don't know.
    """)
    bot.reply("knock knock", "Who's there?")
    bot.reply("Canoe", "Canoe who?")
    bot.reply("Canoe help me with my homework?", "Haha! Canoe help me with my homework!")
    bot.reply("hello", "I don't know.")
    test.done()

exports.test_continuations = (test) ->
    bot = new TestCase(test, """
        + tell me a poem
        - There once was a man named Tim,\\s
        ^ who never quite learned how to swim.\\s
        ^ He fell off a dock, and sank like a rock,\\s
        ^ and that was the end of him.
    """)
    bot.reply("Tell me a poem.", "There once was a man named Tim,
        who never quite learned how to swim.
        He fell off a dock, and sank like a rock,
        and that was the end of him.")
    test.done()

exports.test_redirects = (test) ->
    bot = new TestCase(test, """
        + hello
        - Hi there!

        + hey
        @ hello

        + hi there
        - {@hello}
    """)
    bot.reply("hello", "Hi there!")
    bot.reply("hey", "Hi there!")
    bot.reply("hi there", "Hi there!")
    test.done()

exports.test_conditionals = (test) ->
    bot = new TestCase(test, """
        + i am # years old
        - <set age=<star>>OK.

        + what can i do
        * <get age> == undefined => I don't know.
        * <get age> >  25 => Anything you want.
        * <get age> == 25 => Rent a car for cheap.
        * <get age> >= 21 => Drink.
        * <get age> >= 18 => Vote.
        * <get age> <  18 => Not much of anything.

        + am i your master
        * <get master> == true => Yes.
        - No.
    """)
    age_q = "What can I do?"
    bot.reply(age_q, "I don't know.")

    ages =
        '16' : "Not much of anything."
        '18' : "Vote."
        '20' : "Vote."
        '22' : "Drink."
        '24' : "Drink."
        '25' : "Rent a car for cheap."
        '27' : "Anything you want."
    for age of ages
        if (!ages.hasOwnProperty(age))
            continue
        bot.reply("I am " + age + " years old.", "OK.")
        bot.reply(age_q, ages[age])

    bot.reply("Am I your master?", "No.")
    bot.rs.setUservar(bot.username, "master", "true")
    bot.reply("Am I your master?", "Yes.")
    test.done()

exports.test_embedded_tags = (test) ->
    bot = new TestCase(test, """
        + my name is *
        * <get name> != undefined => <set oldname=<get name>>I thought\\s
          ^ your name was <get oldname>?
          ^ <set name=<formal>>
        - <set name=<formal>>OK.

        + what is my name
        - Your name is <get name>, right?

        + html test
        - <set name=<b>Name</b>>This has some non-RS <em>tags</em> in it.
    """)
    bot.reply("What is my name?", "Your name is undefined, right?")
    bot.reply("My name is Alice.", "OK.")
    bot.reply("My name is Bob.", "I thought your name was Alice?")
    bot.reply("What is my name?", "Your name is Bob, right?")
    bot.reply("HTML Test", "This has some non-RS <em>tags</em> in it.")
    test.done()

exports.test_set_uservars = (test) ->
    bot = new TestCase(test, """
        + what is my name
        - Your name is <get name>.

        + how old am i
        - You are <get age>.
    """)
    bot.rs.setUservars(bot.username, {
        "name": "Aiden",
        "age": 5,
    })
    bot.reply("What is my name?", "Your name is Aiden.")
    bot.reply("How old am I?", "You are 5.")
    test.done()

exports.test_questionmark = (test) ->
  bot = new TestCase(test, """
    + google *
    - <a href="https://www.google.com/search?q=<star>">Results are here</a>
  """)
  bot.reply("google coffeescript",
    '<a href="https://www.google.com/search?q=coffeescript">Results are here</a>'
  )
  test.done()

################################################################################
#  Object Macro Tests
################################################################################

exports.test_js_objects = (test) ->
    bot = new TestCase(test, """
        > object nolang
            return "Test w/o language."
        < object

        > object wlang javascript
            return "Test w/ language."
        < object

        > object reverse javascript
            var msg = args.join(" ");
            console.log(msg);
            return msg.split("").reverse().join("");
        < object

        > object broken javascript
            return "syntax error
        < object

        > object foreign perl
            return "Perl checking in!"
        < object

        + test nolang
        - Nolang: <call>nolang</call>

        + test wlang
        - Wlang: <call>wlang</call>

        + reverse *
        - <call>reverse <star></call>

        + test broken
        - Broken: <call>broken</call>

        + test fake
        - Fake: <call>fake</call>

        + test perl
        - Perl: <call>foreign</call>
    """)
    bot.reply("Test nolang", "Nolang: Test w/o language.")
    bot.reply("Test wlang", "Wlang: Test w/ language.")
    bot.reply("Reverse hello world.", "dlrow olleh")
    bot.reply("Test broken", "Broken: [ERR: Object Not Found]")
    bot.reply("Test fake", "Fake: [ERR: Object Not Found]")
    bot.reply("Test perl", "Perl: [ERR: Object Not Found]")
    test.done()

exports.test_disabled_js_language = (test) ->
    bot = new TestCase(test, """
        > object test javascript
            return 'JavaScript here!'
        < object

        + test
        - Result: <call>test</call>
    """)
    bot.reply("test", "Result: JavaScript here!")
    bot.rs.setHandler("javascript", undefined)
    bot.reply("test", "Result: [ERR: No Object Handler]")
    test.done()

exports.test_get_variable = (test) ->
    bot = new TestCase(test, """
        ! var test_var = test

        > object test_get_var javascript
            var uid   = rs.currentUser();
            var name  = "test_var";
            return rs.getVariable(uid, name);
        < object

        + show me var
        - <call> test_get_var </call>
    """)
    bot.reply("show me var", "test")
    test.done()

################################################################################
#  Topic Tests
################################################################################

exports.test_punishment_topic = (test) ->
    bot = new TestCase(test, """
        + hello
        - Hi there!

        + swear word
        - How rude! Apologize or I won't talk to you again.{topic=sorry}

        + *
        - Catch-all.

        > topic sorry
            + sorry
            - It's ok!{topic=random}

            + *
            - Say you're sorry!
        < topic
    """)
    bot.reply("hello", "Hi there!")
    bot.reply("How are you?", "Catch-all.")
    bot.reply("Swear word!", "How rude! Apologize or I won't talk to you again.")
    bot.reply("hello", "Say you're sorry!")
    bot.reply("How are you?", "Say you're sorry!")
    bot.reply("Sorry!", "It's ok!")
    bot.reply("hello", "Hi there!")
    bot.reply("How are you?", "Catch-all.")
    test.done()

exports.test_topic_inheritance = (test) ->
    RS_ERR_MATCH = "ERR: No Reply Matched"
    bot = new TestCase(test, """
        > topic colors
            + what color is the sky
            - Blue.

            + what color is the sun
            - Yellow.
        < topic

        > topic linux
            + name a red hat distro
            - Fedora.

            + name a debian distro
            - Ubuntu.
        < topic

        > topic stuff includes colors linux
            + say stuff
            - \"Stuff.\"
        < topic

        > topic override inherits colors
            + what color is the sun
            - Purple.
        < topic

        > topic morecolors includes colors
            + what color is grass
            - Green.
        < topic

        > topic evenmore inherits morecolors
            + what color is grass
            - Blue, sometimes.
        < topic
    """)
    bot.rs.setUservar(bot.username, "topic", "colors")
    bot.reply("What color is the sky?", "Blue.")
    bot.reply("What color is the sun?", "Yellow.")
    bot.reply("What color is grass?", RS_ERR_MATCH)
    bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
    bot.reply("Name a Debian distro.", RS_ERR_MATCH)
    bot.reply("Say stuff.", RS_ERR_MATCH)

    bot.rs.setUservar(bot.username, "topic", "linux")
    bot.reply("What color is the sky?", RS_ERR_MATCH)
    bot.reply("What color is the sun?", RS_ERR_MATCH)
    bot.reply("What color is grass?", RS_ERR_MATCH)
    bot.reply("Name a Red Hat distro.", "Fedora.")
    bot.reply("Name a Debian distro.", "Ubuntu.")
    bot.reply("Say stuff.", RS_ERR_MATCH)

    bot.rs.setUservar(bot.username, "topic", "stuff")
    bot.reply("What color is the sky?", "Blue.")
    bot.reply("What color is the sun?", "Yellow.")
    bot.reply("What color is grass?", RS_ERR_MATCH)
    bot.reply("Name a Red Hat distro.", "Fedora.")
    bot.reply("Name a Debian distro.", "Ubuntu.")
    bot.reply("Say stuff.", '"Stuff."')

    bot.rs.setUservar(bot.username, "topic", "override")
    bot.reply("What color is the sky?", "Blue.")
    bot.reply("What color is the sun?", "Purple.")
    bot.reply("What color is grass?", RS_ERR_MATCH)
    bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
    bot.reply("Name a Debian distro.", RS_ERR_MATCH)
    bot.reply("Say stuff.", RS_ERR_MATCH)

    bot.rs.setUservar(bot.username, "topic", "morecolors")
    bot.reply("What color is the sky?", "Blue.")
    bot.reply("What color is the sun?", "Yellow.")
    bot.reply("What color is grass?", "Green.")
    bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
    bot.reply("Name a Debian distro.", RS_ERR_MATCH)
    bot.reply("Say stuff.", RS_ERR_MATCH)

    bot.rs.setUservar(bot.username, "topic", "evenmore")
    bot.reply("What color is the sky?", "Blue.")
    bot.reply("What color is the sun?", "Yellow.")
    bot.reply("What color is grass?", "Blue, sometimes.")
    bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
    bot.reply("Name a Debian distro.", RS_ERR_MATCH)
    bot.reply("Say stuff.", RS_ERR_MATCH)

    test.done()

################################################################################
#  Parser option tests
################################################################################

exports.test_concat = (test) ->
    bot = new TestCase(test, """
        // Default concat mode = none
        + test concat default
        - Hello
        ^ world!

        ! local concat = space
        + test concat space
        - Hello
        ^ world!

        ! local concat = none
        + test concat none
        - Hello
        ^ world!

        ! local concat = newline
        + test concat newline
        - Hello
        ^ world!

        // invalid concat setting is equivalent to 'none'
        ! local concat = foobar
        + test concat foobar
        - Hello
        ^ world!

        // the option is file scoped so it can be left at
        // any setting and won't affect subsequent parses
        ! local concat = newline
    """)
    bot.extend("""
        // concat mode should be restored to the default in a
        // separate file/stream parse
        + test concat second file
        - Hello
        ^ world!
    """)

    bot.reply("test concat default", "Helloworld!")
    bot.reply("test concat space", "Hello world!")
    bot.reply("test concat none", "Helloworld!")
    bot.reply("test concat newline", "Hello\nworld!")
    bot.reply("test concat foobar", "Helloworld!")
    bot.reply("test concat second file", "Helloworld!")

    test.done()

################################################################################
#  Unicode Tests
################################################################################

exports.test_unicode = (test) ->
    bot = new TestCase(test, """
        ! sub who's = who is

        + äh
        - What's the matter?

        + ブラッキー
        - エーフィ

        // Make sure %Previous continues working in UTF-8 mode.
        + knock knock
        - Who's there?

        + *
        % who is there
        - <sentence> who?

        + *
        % * who
        - Haha! <sentence>!

        // And with UTF-8.
        + tëll më ä pöëm
        - Thërë öncë wäs ä män nämëd Tïm

        + more
        % thërë öncë wäs ä män nämëd tïm
        - Whö nëvër qüïtë lëärnëd höw tö swïm

        + more
        % whö nëvër qüïtë lëärnëd höw tö swïm
        - Hë fëll öff ä döck, änd sänk lïkë ä röck

        + more
        % hë fëll öff ä döck änd sänk lïkë ä röck
        - Änd thät wäs thë ënd öf hïm.
    """, {"utf8": true})

    bot.reply("äh", "What's the matter?")
    bot.reply("ブラッキー", "エーフィ")
    bot.reply("knock knock", "Who's there?")
    bot.reply("Orange", "Orange who?")
    bot.reply("banana", "Haha! Banana!")
    bot.reply("tëll më ä pöëm", "Thërë öncë wäs ä män nämëd Tïm")
    bot.reply("more", "Whö nëvër qüïtë lëärnëd höw tö swïm")
    bot.reply("more", "Hë fëll öff ä döck, änd sänk lïkë ä röck")
    bot.reply("more", "Änd thät wäs thë ënd öf hïm.")
    test.done()

exports.test_punctuation = (test) ->
  bot = new TestCase(test, """
    + hello bot
    - Hello human!
  """, {"utf8": true})

  bot.reply("Hello bot", "Hello human!")
  bot.reply("Hello, bot!", "Hello human!")
  bot.reply("Hello: Bot", "Hello human!")
  bot.reply("Hello... bot?", "Hello human!")

  bot.rs.unicodePunctuation = new RegExp(/xxx/g)
  bot.reply("Hello bot", "Hello human!")
  bot.reply("Hello, bot!", "ERR: No Reply Matched")
  test.done()

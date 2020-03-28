# this is example rakuscript

# define some saveable values
define a = 3
define b = 0.3
define e = "some string"
define d = []
define e = {}
define f = false

# you can overwrite var created in in another script before
x += 40

# define new charater
charater player name "Protag-kun"
character eva name "Eva"

# eva like us
charater eva stat like = true

# this is just some gdscpript code
gd: var gdvar = true

# you can make funcs
func test():
  "this is from test func"

# this is dialog
dialog test_dialog:

  # this is how you say things
  "Hi!"

  eva "Hi player!"

  # you can ask player for his name
  use ask with value player.name
  eva "What is your name, player?"

  # you can give player choice
  use menu
  "what do you want"
    "first choice":
      "this is first choice"

    "test test func":
      test()

    "go to other dialog":
      jump Scene_id/Node_name/dialog_name

    "go to scene with mini-game":
      jump Minigame

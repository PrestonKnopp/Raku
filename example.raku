# this is example rakuscript

# define some saveable values
define a = 3
define:
  b = 0.3
  e = "some string"
  d = []
  e = {}
  f = false

# you can overwrite var created in in another script before
x += 40

# define new charater
charater player "Protag-kun":
  color = green # this will set this characte name label using `green` color defined in Rakugo/main.gd


# I assume that eva is define in scene using nodes
# eva like us
charater eva stats.like = true
   

# this is just some gdscpript code
gd: var gdvar = true

# you can make funcs
func test_func():
  "this is from test func"

# this is dialog
dialog test_dialog:

  # you can use diffrent style of displaying dialog ui:
  kind fullscreen
  "This is some intro into the story."

  # this is how you say things
  "Hi!"

  # this is how show eva
  show eva

  # this how you show eva in maid dress
  show eva maid

  # this how give eva smile
  show eva smile

  # you can combie this
  show eva maid sad

  # you can ask player for his name
  ask with value player.name
  eva "Hi! What is your name?"

  # you can use vars, emoji and markups in dialog
  eva "Nice to meet you {b}[player.name]{/b} {:smile:}"

  # you can give player choice
  menu: reuseble_menu
  "what do you want"
    "first choice":
      "this is first choice"

    "test test_func":
      test_func()

    "go to other dialog":
      jump Scene_id/Node_name/dialog_name

    "go to scene with mini-game":
      jump Minigame
     
    "show this menu again":
      reuseble_menu()
    

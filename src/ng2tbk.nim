import
  nimgame2 / [
    nimgame,
    settings,
    types,
  ],
  data,
  scene / [
    intro,
    title,
    arena,
  ]

game = newGame()
if game.init(GameDim.w, GameDim.h, title = GameTitle,
             bgColor = Color(r: 127, g: 127, b: 127, a: 127)):
  # Init
  game.setResizable(true)
  game.minSize = (GameDim.w, GameDim.h)
  game.centrify()
  loadData()
  #colliderOutline = true
  #showInfo = true
  # Scenes
  introScene = newIntroScene()
  titleScene = newTitleScene()
  arenaScene = newArenaScene()
  # Run
  game.scene = introScene
  run game

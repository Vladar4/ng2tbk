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
             bgColor = Color(r: 0, g: 0, b: 0, a: 255)):
  # Init
  game.setResizable(true)
  game.minSize = (GameDim.w, GameDim.h)
  game.windowSize = (GameDim * 2)
  game.centrify()
  loadData()
  game.icon = gameIconSurface
  #colliderOutline = true
  #showInfo = true
  # Scenes
  introScene = newIntroScene()
  titleScene = newTitleScene()
  arenaScene = newArenaScene()
  # Run
  game.scene = introScene
  run game

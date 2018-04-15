import
  nimgame2 / [
    assets,
    audio,
    nimgame,
    entity,
    graphic,
    input,
    scene,
    settings,
    textgraphic,
    tween,
    types,
  ],
  ../data,
  ../character,
  ../lifemeter


type
  ArenaScene* = ref object of Scene
    bg: Entity
    left, right: Character
    leftLife, rightLife: LifeMeter
    twoPlayers*: bool
    victoryChannel*: Channel


proc getCharacters(): seq[Entity] =
  game.scene.findAll "character"


proc init*(scene: ArenaScene) =
  init Scene scene


proc free*(scene: ArenaScene) =
  discard


method show*(scene: ArenaScene) =
  scene.clear()

  # bg
  scene.bg = newEntity()
  scene.bg.graphic = gfxData["bg"]
  scene.bg.layer = -100
  scene.add scene.bg

  # left
  scene.left = newCharacter(gfxData["blue_player"], player1=true)
  scene.left.getCharacters = getCharacters
  scene.left.pos = GameDim / 2
  scene.left.pos.x = 0.0
  scene.add scene.left

  scene.leftLife = newLifeMeter(scene.left)
  scene.leftLife.pos = (10.0, float GameDim.h - 10)
  scene.add scene.leftLife

  # right
  if scene.twoPlayers:
    scene.right = newCharacter(gfxData["red_player"], mirrored=true, player2=true)
  else:
    scene.right = newCharacter(gfxData["red_player"], mirrored=true)
  scene.right.getCharacters = getCharacters
  scene.right.pos = GameDim / 2
  scene.right.pos.x = float(GameDim.w - scene.right.sprite.dim.w)
  scene.add scene.right

  scene.rightLife = newLifeMeter(scene.right, true)
  scene.rightLife.pos = (float GameDim.w - 10, float GameDim.h - 10)
  scene.add scene.rightLife

  scene.victoryChannel = -1


proc newArenaScene*(): ArenaScene =
  new result, free
  init result


method update*(scene: ArenaScene, elapsed: float) =
  scene.updateScene elapsed
  if ScancodeF10.pressed:
    colliderOutline = not colliderOutline
  if ScancodeF11.pressed:
    showInfo = not showInfo

  if scene.victoryChannel < 0:
    if scene.left.killed or scene.right.killed:
      scene.victoryChannel = sfxData["victory"].play()
  else:
    if not playing scene.victoryChannel:
      game.scene = titleScene


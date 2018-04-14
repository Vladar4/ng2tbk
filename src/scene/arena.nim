import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    input,
    scene,
    settings,
    textgraphic,
    tween,
    types,
  ],
  ../data,
  ../character


type
  ArenaScene* = ref object of Scene
    left, right: Character
    twoPlayers*: bool


proc getCharacters(): seq[Entity] =
  game.scene.findAll "character"


proc init*(scene: ArenaScene) =
  init Scene scene


proc free*(scene: ArenaScene) =
  discard


method show*(scene: ArenaScene) =
  scene.clear()

  # left
  scene.left = newCharacter(gfxData["player"], player1=true)
  scene.left.getCharacters = getCharacters
  scene.left.pos = GameDim / 2
  scene.left.pos.x = 0.0
  scene.add scene.left

  # right
  if scene.twoPlayers:
    scene.right = newCharacter(gfxData["player"], mirrored=true, player2=true)
  else:
    scene.right = newCharacter(gfxData["player"], mirrored=true)
  scene.right.getCharacters = getCharacters
  scene.right.pos = GameDim / 2
  scene.right.pos.x = float(GameDim.w - scene.right.sprite.dim.w)
  scene.add scene.right


proc newArenaScene*(): ArenaScene =
  new result, free
  init result


method update*(scene: ArenaScene, elapsed: float) =
  scene.updateScene elapsed
  if ScancodeF10.pressed:
    colliderOutline = not colliderOutline
  if ScancodeF11.pressed:
    showInfo = not showInfo


import
  nimgame2 / [
    plugin/tar,
    assets,
    audio,
    input,
    mosaic,
    scene,
    texturegraphic,
    truetypefont,
    types,
  ]


type
  ControlScheme* = object
    a*, b*: GeneralInput


const
  GameTitle* = "Two-Button Knight"
  #TODO GameIcon* = "data/"
  GameVersion* = "0.1"
  GameInfo* = GameTitle & " " & GameVersion & " Copyright © 2018 Vladar"
  GameDim*: Dim = (640, 360)
  WindowDim* = GameDim * 2
  DefaultFont* = "data/fnt/Luxembourg_1910.ttf"
  Framerate* = 1/12
  CharacterOffset* = 60
  CharacterOffset2* = CharacterOffset * 2


var
  introScene*, titleScene*, arenaScene*: Scene
  defaultFont*, smallFont*: TrueTypeFont
  gfxData*: Assets[TextureGraphic]
  sfxData*: Assets[Sound]
  musData*: Assets[Music]

  player1key* = ControlScheme(
    a: GeneralInput(
      kind: giKeyboard,
      keyboard: GeneralInputKeyboard(key: ScancodeX)),
    b: GeneralInput(
      kind: giKeyboard,
      keyboard: GeneralInputKeyboard(key: ScancodeZ))
  )

  player2key* = ControlScheme(
    a: GeneralInput(
      kind: giKeyboard,
      keyboard: GeneralInputKeyboard(key: ScancodeComma)),
    b: GeneralInput(
      kind: giKeyboard,
      keyboard: GeneralInputKeyboard(key: ScancodePeriod))
  )


proc loadData*() =
  var t: TarFile
  if t.openz "data.tar.gz":
    # Font
    defaultFont = newTrueTypeFont()
    if not defaultFont.load(t.read DefaultFont, 48):
      write stdout, "ERROR: Can't load font: ", DefaultFont
    smallFont = newTrueTypeFont()
    if not smallFont.load(t.read DefaultFont, 24):
      write stdout, "ERROR: Can't load font: ", DefaultFont
    # GFX
    gfxData = newAssets[TextureGraphic](t.contents "data/gfx",
      proc(file: string): TextureGraphic = newTextureGraphic(t.read file))
    # SFX
    sfxData = newAssets[Sound](t.contents "data/sfx",
      proc(file: string): Sound = newSound(t.read file))
    # MUS TODO
    #[
    musData = newAssets[Music](t.contents "data/mus",
      proc(file: string): Music = newMusic(t.read file))
    playlist = newPlaylist()
    for track in musData.values:
      playlist.list.add track
    ]#
  else:
    # Font
    defaultFont = newTrueTypeFont()
    if not defaultFont.load(DefaultFont, 48):
      write stdout, "ERROR: Can't load font: ", DefaultFont
    smallFont = newTrueTypeFont()
    if not smallFont.load(DefaultFont, 24):
      write stdout, "ERROR: Can't load font: ", DefaultFont
    # GFX
    gfxData = newAssets[TextureGraphic]("data/gfx",
      proc(file: string): TextureGraphic = newTextureGraphic(file))
    # SFX
    sfxData = newAssets[Sound]("data/sfx",
      proc(file: string): Sound = newSound(file))
    # MUS TODO
    #[
    musData = newAssets[Music]("data/mus",
      proc(file: string): Music = newMusic(file))
    playlist = newPlaylist()
    for track in musData.values:
      playlist.list.add track
    ]#

proc freeData*() =
  defaultFont.free()
  for gfx in gfxData.values:
    gfx.free()
  for sfx in sfxData.values:
    sfx.free()


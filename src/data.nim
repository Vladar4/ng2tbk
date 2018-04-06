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


const
  GameTitle* = "ng2lgj18"
  #TODO GameIcon* = "data/"
  GameVersion* = "0.1"
  GameInfo* = GameTitle & " " & GameVersion & " Copyright © 2018 Vladar"
  GameDim*: Dim = (640, 360)
  WindowDim* = GameDim * 2
  DefaultFont* = "data/fnt/Luxembourg_1910.ttf"


var
  introScene*, titleScene*: Scene
  defaultFont*: TrueTypeFont
  gfxData*: Assets[TextureGraphic]
  sfxData*: Assets[Sound]
  musData*: Assets[Music]


proc loadData*() =
  # TODO implement TAR loading
  # Font
  defaultFont = newTrueTypeFont()
  if not defaultFont.load(DefaultFont, 32):
    write stdout, "ERROR: Can't load font: ", DefaultFont
  # GFX TODO
  #[
  gfxData = newAssets[TextureGraphic]("data/gfx",
    proc(file: string): TextureGraphic = newTextureGraphic(file))
  ]#
  # SFX TODO
  #[
  sfxData = newAssets[TextureGraphic]("data/sfx",
    proc(file: string): Sound = newSound(file))
  ]#
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


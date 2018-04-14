import
  strutils,
  nimgame2 / [
    assets,
    audio,
    entity,
    nimgame,
    texturegraphic,
    types,
  ],
  data


type
  Gong* = ref object of Entity
    command*: proc()
    hitCooldown*: float


const
  HitCooldown = Framerate * 6
  Anim = [[0, 1, 2, 3],
          [1, 2, 3, 0],
          [2, 3, 0, 1],
          [3, 0, 1, 2]]


proc init*(gong: Gong, graphic: TextureGraphic, anim = 0, command: proc() = nil) =
  gong.initEntity()
  gong.command = command
  gong.layer = -10
  gong.tags.add "gong"
  gong.graphic = graphic
  gong.initSprite((180, 180))
  discard gong.addAnimation("idle", Anim[anim], Framerate * 2)
  gong.play("idle", -1)
  gong.collider = newCircleCollider(gong, (90, 105), 25)


proc newGong*(graphic: TextureGraphic, anim = 0, command: proc() = nil): Gong =
  new result
  init result, graphic, anim, command


method update*(gong: Gong, elapsed: float) =
  gong.updateEntity elapsed
  if gong.hitCooldown > 0:
    gong.hitCooldown -= elapsed


method onCollide*(gong: Gong, target: Entity) =
  if gong.hitCooldown <= 0:
    for tag in target.collider.tags:
      if "attack" in tag:
        discard sfxData["gong"].play()
        if gong.command != nil:
          gong.command()
        gong.hitCooldown = HitCooldown
        return


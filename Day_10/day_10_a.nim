import sdl2/sdl
import strutils, strscans, sets, sequtils, times, tables

let max_num = 9999999
#[
let speed = 100
let skip_num = 10
let update_frame = 1
]#
let speed = 1
let skip_num = 10453
let update_frame = 60
let rect_side = 35
let file_name = "d10_input.txt"

const
  Title = "SDL2 App"
  ScreenW = 1000 # Window width
  ScreenH = 500 # Window height
  WindowFlags = 0
  RendererFlags = sdl.RendererAccelerated or sdl.RendererPresentVsync

type Light = object
  x, y: int
  dx, dy: int

var all_points = newSeq[Light]()

var min_x = max_num
var min_y = max_num
var max_x = -max_num
var max_y = -max_num

for line in lines file_name:
  var pos_x, pos_y, vel_x, vel_y: int
  if scanf(line, "position=<$s$i,$s$i> velocity=<$s$i,$s$i>", pos_x, pos_y, vel_x, vel_y):
    all_points.add(Light(x:pos_x, y: pos_y, dx: vel_x, dy: vel_y))
    if pos_x > max_x:
      max_x = pos_x
    if pos_y > max_y:
      max_y = pos_y
    if pos_x < min_x:
      min_x = pos_x
    if pos_y < min_y:
      min_y = pos_y
  else:
    echo "skipped line ", line

echo all_points.len
echo "(", min_x, ", ", min_y, ") to (", max_x, ", ",max_y, ")"

var range_x = max_x - min_x
var range_y = max_y - min_y

echo "size: ", range_x , " x ", range_y 

var proportion_x = (ScreenW - 20) / range_x
var proportion_y = (ScreenH - 20) / range_y

var margin_x = 0
var margin_y = 0

margin_x = int(float(min_x) * proportion_x)
margin_y = int(float(min_y) * proportion_y)

echo "proportion: ", proportion_x, " x ", proportion_y

proc update_points(seq_lights: seq[Light], debug: bool) : seq[Light] =
  result = newSeq[Light]()
  min_x = max_num
  min_y = max_num
  max_x = -max_num
  max_y = -max_num
  for ll in seq_lights:
    let next_pos_x = ll.x + speed * ll.dx
    let next_pos_y = ll.y + speed * ll.dy
    result.add(Light(x: next_pos_x, y: next_pos_y, dx: ll.dx, dy: ll.dy))

    if next_pos_x > max_x:
      max_x = next_pos_x
    if next_pos_y > max_y:
      max_y = next_pos_y
    if next_pos_x < min_x:
      min_x = next_pos_x
    if next_pos_y < min_y:
      min_y = next_pos_y
  
  range_x = max_x - min_x
  range_y = max_y - min_y
  proportion_x = ScreenW / range_x
  proportion_y = ScreenH / range_y

  margin_x = int(float(min_x) * proportion_x)
  margin_y = int(float(min_y) * proportion_y)

  if debug:
    echo "prop: ", proportion_x, " x ", proportion_y, " range: ", range_x, " x ", range_y,
      " min: (", min_x, ", ", min_y, ") to (", max_x, ", ", max_y, ")"
    echo "min screen: (", int(float(min_x-min_x) * proportion_x), ", ", 
      int(float(min_y-min_y) * proportion_y), 
      ") max: (", int(float(max_x-min_x) * proportion_x), ", ", 
      int(float(max_y-min_y) * proportion_y), ")"

  return result

for ii in 1..skip_num:
  all_points = update_points(all_points, false)

type
  App = ref AppObj
  AppObj = object
    window*: sdl.Window # Window pointer
    renderer*: sdl.Renderer # Rendering state pointer


# Initialization sequence
proc init(app: App): bool =
  # Init SDL
  if sdl.init(sdl.InitVideo) != 0:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't initialize SDL: %s",
                    sdl.getError())
    return false

  # Create window
  app.window = sdl.createWindow(
    Title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    ScreenW,
    ScreenH,
    WindowFlags)
  if app.window == nil:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't create window: %s",
                    sdl.getError())
    return false

  # Create renderer
  app.renderer = sdl.createRenderer(app.window, -1, RendererFlags)
  if app.renderer == nil:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't create renderer: %s",
                    sdl.getError())
    return false

  # Set draw color
  if app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
    sdl.logWarn(sdl.LogCategoryVideo,
                "Can't set draw color: %s",
                sdl.getError())
    return false

  sdl.logInfo(sdl.LogCategoryApplication, "SDL initialized successfully")
  return true


# Shutdown sequence
proc exit(app: App) =
  app.renderer.destroyRenderer()
  app.window.destroyWindow()
  sdl.logInfo(sdl.LogCategoryApplication, "SDL shutdown completed")
  sdl.quit()


# Event handling
# Return true on app shutdown request, otherwise return false
proc events(): bool =
  result = false
  var e: sdl.Event

  while sdl.pollEvent(addr(e)) != 0:

    # Quit requested
    if e.kind == sdl.Quit:
      return true

    # Key pressed
    elif e.kind == sdl.KeyDown:
      # Show what key was pressed
      sdl.logInfo(sdl.LogCategoryApplication, "Pressed %s", $e.key.keysym.sym)

      # Exit on Escape key press
      if e.key.keysym.sym == sdl.K_Escape:
        return true


########
# MAIN #
########

proc draw_points(renderer: Renderer, lights: seq[Light]) =
  discard renderer.setRenderDrawColor(0xFF, 0x00, 0x00, 0xFF)
  let numPoints = lights.len
  var points = newSeq[sdl.Rect]()
  for i in 0..numPoints-1:
    points.add(sdl.Rect(x: int(float(lights[i].x - min_x) * proportion_x) - rect_side div 2, 
    y: int(float(lights[i].y - min_y) * proportion_y) - rect_side div 2, 
    w: rect_side, h: rect_side))
  discard renderer.renderFillRects(addr(points[0]), numPoints)

var total_frames = 0

var
  app = App(window: nil, renderer: nil)
  done = false # Main loop exit condition

if init(app):

  echo "Press any key..."

  # Main loop
  var frame = 0
  while not done:
    # Clear screen with draw color
    discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
    if app.renderer.renderClear() != 0:
      sdl.logWarn(sdl.LogCategoryVideo,
                  "Can't clear screen: %s",
                  sdl.getError())

    if frame >= update_frame:
      all_points = update_points(all_points, true)
      total_frames += 1
      frame = 0
    else: 
      frame += 1
    draw_points(app.renderer, all_points)

    # Update renderer
    app.renderer.renderPresent()
    # Event handling
    done = events()

echo "total frames: ",total_frames
# Shutdown
exit(app)


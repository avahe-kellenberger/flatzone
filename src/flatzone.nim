include karax/prelude

import std/[json, tables, strutils, uri]

type
  Character = object
    name: string
    generalGameplan: string
    nairFSDair: string
    chefAngleAtLedge: int
    doesDsmashHitAllLedgeOptionsButJump: bool
    whichIsHighestMoveToHitLedgehang: string
    top3StageBans: seq[string]
    vods: seq[string]

const characters: seq[Character] = static:
  parseJson(staticRead("../assets/data.json")).to(seq[flatzone.Character])

var characterLookup = initTable[string, flatzone.Character]()
for character in characters:
  characterLookup[character.name] = character

proc createTitleBar(): VNode =
  result = buildHtml(tdiv(class="top-bar")):
    link(rel = "stylesheet", `type` = "text/css", href = "main.css")
    h1(class="title"):
      text "Flatzone"

    a(href = "#/search"):
      h2: text "Search"

    a(href = "#/news"):
      h2: text "News"

    a(href = "#/donations"):
      h2: text "Donations"

proc normalizeCharacterName(name: string): string =
  return
    toLower(name)
    .replace(" ", "_")
    .replace(".", "")
    .replace("&", "and")

template characterImg(name: string): string =
  "../assets/images/" & normalizeCharacterName(name) 

proc createCharacterPage(character: string): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()
    img(class = "character-tile", src = characterImg(character) & ".png")

proc createCharacterTile(character: Character): VNode =
  result = buildHtml():
    a(class="character-tile", href = cstring("#/" & character.name)):
      img(src = characterImg(character.name) & ".png")
      h1(class="character-name"): text character.name

proc createHomePage(): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()
    tdiv(class="characters-container"):
      for character in characters:
        createCharacterTile(character)

proc create404Page(): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()
    h2: text "404 - Not Found"

proc createSite(data: RouterData): VNode =
  if data.hashPart.len == 0:
    return createHomePage()
  elif data.hashPart.startsWith("#/"):
    let hashPartEnd = decodeUrl(($data.hashPart)[2..^1])
    if characterLookup.hasKey(hashPartEnd):
      return createCharacterPage(hashPartEnd)

  return create404Page()

setRenderer createSite

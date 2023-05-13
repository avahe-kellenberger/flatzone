include karax/prelude

import std/[json, tables, strutils, uri]

type
  Character = object
    number: int
    name: string
    weight: int
    fallSpeed: float
    airdodge: int
    escapeOption: int
    generalGameplan: string
    nairFSDair: string
    chefAngleAtLedge: int
    doesDsmashHitAllLedgeOptionsButJump: bool
    whichIsHighestMoveToHitLedgehang: string
    top3StageBans: string
    vods: seq[string]

const characters: seq[Character] = static:
  parseJson(staticRead("../assets/data.json")).to(seq[flatzone.Character])

var characterLookup = initTable[string, flatzone.Character]()
for character in characters:
  characterLookup[character.name] = character

proc createTitleBar(): VNode =
  result = buildHtml(tdiv(class="top-bar")):
    link(rel = "stylesheet", `type` = "text/css", href = "main.css")
    h1(class="title"): text "Flatzone"

    a(href = "#/search"):
      h2: text "Search"

    a(href = "#/news"):
      h2: text "News"

    a(href = "#/donations"):
      h2: text "Donations"

proc createCharacterPage(character: string): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()
    h1: text character

proc createCharacterTile(character: Character): VNode =
  result = buildHtml(tdiv(class="")):
    a(href = cstring("#/" & character.name)):
      h2: text character.name

proc createHomePage(): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()
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
    echo hashPartEnd
    if characterLookup.hasKey(hashPartEnd):
      return createCharacterPage(hashPartEnd)

  return create404Page()

setRenderer createSite

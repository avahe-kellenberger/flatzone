include karax/prelude

import std/[json, tables, strutils, uri, dom, strformat, os]
import fuzzy

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

proc normalizeCharacterName(name: string): string =
  return
    toLower(name)
    .replace(" ", "_")
    .replace(".", "")
    .replace("&", "and")

const characters: seq[Character] = static:
  parseJson(staticRead("../assets/data.json")).to(seq[flatzone.Character])

var characterHtmlPages =
  static:
    var result = initTable[string, string]()
    for character in characters:
      let name = normalizeCharacterName(character.name)
      let text = staticRead(fmt"../html/{name}.html")
      result[name] = text
    result

var characterLookup = initTable[string, flatzone.Character]()
for character in characters:
  characterLookup[character.name] = character

var characterDomTiles: Table[string, VNode] = initTable[string, VNode]()

proc createTitleBar(): VNode =
  result = buildHtml(tdiv(class="top-bar")):
    link(rel = "stylesheet", `type` = "text/css", href = "main.css")
    h1(class="title"):
      a(href=cstring""):
        text "Flatzone"

    a(href = cstring "https://discord.gg/HBkR7eH", target = "_blank"):
      h2(class="title-link"):
        text "GnW Discord"

    # TODO: Add any other links we want.

template characterImg(name: string): string =
  "../assets/images/" & normalizeCharacterName(name) 

proc createCharacterPage(character: string): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()
    img(class = "mu-character-tile", src = characterImg(character) & ".png"):
      h1(class="character-name"):
        text character

    tdiv(class="mu-info-text"):
      let charName = normalizeCharacterName(character)
      verbatim(characterHtmlPages[charName])

proc createCharacterTile(character: Character): VNode =
  result = buildHtml():
    a(class="character-tile", href = cstring("#/" & character.name)):
      img(src = characterImg(character.name) & ".png")
      h1(class="character-name"):
        text character.name

  # Add tile to list so we can filter by search.
  characterDomTiles[
    character.name.toLower().replace(".", "")
  ] = result

proc filterBySearch(searchText: string) =
  for charName, charTile in characterDomTiles.pairs():
    if searchText.len == 0 or score(searchText, charName) > 0:
      charTile.dom.style.display = ""
    else:
      charTile.dom.style.display = "none"

proc createHomePage(): VNode =
  result = buildHtml(tdiv(class="")):
    createTitleBar()

    tdiv(class="searchbar-container"):
      input(class="searchbar", placeholder="Search...", setFocus=true):
        proc onkeyup(e: Event, n: VNode) =
          filterBySearch(toLower($e.target.value))

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

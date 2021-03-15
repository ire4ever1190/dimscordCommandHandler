import dimscord, asyncdispatch, strutils
import random
import src/dimscmd
import options

# Initialise everthing
const token = readFile("token").strip()
let discord = newDiscordClient(token)
var cmd = discord.newHandler(applicationID = "742010764302221334") # Must be var
randomize()

proc reply(m: Message, msg: string): Future[Message] {.async.} =
    result = await discord.api.sendMessage(m.channelId, msg)

cmd.addChat("hi") do ():
    ## I say hello back
    discard await msg.reply("Hello")

cmd.addChat("echo") do (toEcho {.help: "The word that you want me to echo"}: string, times: int):
    ## I will repeat what you say
    echo toEcho
    discard await msg.reply(repeat(toEcho & " ", times))

cmd.addChat("echoAll") do (toEcho: seq[string]):
    ## I will say a list of words
    for word in toEcho:
        discard await msg.reply(word)

cmd.addChat("sum") do (nums: seq[int]):
    ## Sums up all your numbers
    var sum = 0
    for num in nums: sum.inc num
    discard msg.reply($sum)
    
cmd.addSlash("hello") do ():
    ## I output to console
    guildID: "479193574341214208"
    echo "I was summoned"

# Do discord events like normal
proc onReady (s: Shard, r: Ready) {.event(discord).} =
    # await cmd.registerCommands()
    echo "Ready as " & $r.user

proc messageCreate (s: Shard, msg: Message) {.event(discord).} =
    echo msg.content
    if msg.author.bot: return
    # Let the magic happen
    discard await cmd.handleMessage("$$", msg) # Returns true if a command was handled
    # Or you can pass a list of prefixes
waitFor discord.startSession()

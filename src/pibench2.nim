#~~
# pibench2
# A dead-simple, multi-threaded performance benchmark.
# copyright (C) iLiquid, 2019
# licensed under the MIT license
#~~

import cpuinfo
import locks, rlocks
import math
import os
import parseopt
import segfaults
import strutils
import terminal
import times
from unicode import toRunes, `$`

type
  EventKind = enum
    evkProgress
    evkFinished
  Event = object
    thread: int
    case kind: EventKind
    of evkProgress:
      progress: float
    of evkFinished:
      result: float
  ThreadParams = tuple
    thread: int
    iterStart, iterEnd: int

var
  threads: seq[Thread[ThreadParams]]
  events: Channel[Event]

template cursorAt(dx, dy: int, body: untyped) =
  stdout.cursorUp(dy)
  stdout.setCursorXPos(dx)
  body
  stdout.setCursorXPos(0)
  stdout.cursorDown(dy)

const
  ProgressBarParts = " ▏▎▍▌▋▊▉█".toRunes

proc progressBar(width: int, progress: float): string =
  let length = float(width) * progress
  for i in 0..<width:
    let fract = length - float(i)
    let part = int max(0, min(floor(fract / 0.125), 8))
    result.add($ProgressBarParts[part])

proc leibnizPi(params: ThreadParams) {.thread.} =
  var
    i = params.iterStart
    part = 0.0
    updateTime = 0
  let
    absIter = params.iterEnd - params.iterStart
    updateInterval = int(absIter / 100000)
  while i < params.iterEnd:
    let den = i * 2 + 1
    part += 1 / den * float(i mod 2 * 2 - 1) * -1
    let absI = i - params.iterStart
    if updateTime >= updateInterval:
      events.send(Event(
        kind: evkProgress,
        thread: params.thread,
        progress: absI / absIter
      ))
      updateTime = 0
    inc(i)
    inc(updateTime)
  events.send(Event(
    kind: evkFinished,
    thread: params.thread,
    result: part
  ))

proc benchmark(threadC: Natural, precision: Natural): float =

  let
    totalIter = 10 ^ precision
    cpuCount = countProcessors()
  if threadC != 0:
    # Calculate the amount of iterations required per thread
    # This is done because in a lot of cases the amount will be uneven
    # (the last thread's ``iterPos[1]`` will not equal ``totalIter``)
    var
      iters: seq[int]
      remainingIter = totalIter
    block calcIterationsPerThread:
      styledEcho(styleBright, "· calculating iterations/thread")
      let baseIter = int(totalIter / threadC)
      for i in 0..<threadC:
        iters.add(baseIter)
        remainingIter -= baseIter
      var i = 0
      while remainingIter > 0:
        inc(iters[i mod len(iters)])
        inc(i)
        dec(remainingIter)
    # Start the benchmark
    let startTime = epochTime()
    block startBenchmark:
      styledEcho(styleBright, "· starting threads")
      threads.setLen(threadC)
      open(events)
      var
        i, iStart = 0
      for t in mitems(threads):
        createThread(t, leibnizPi, (i, iStart, iStart + iters[i]))
        t.pinToCpu(i mod cpuCount)
        iStart += iters[i]
        inc(i)
      echo repeat("\n", int(ceil(threadC / 4)))
    # Listen for incoming events
    block eventLoop:
      stdout.hideCursor()
      var
        finishedThreads = 0
        pi = 0.0
        threadBarWidth = int(min(int terminalWidth() / 4, len($threadC) + 20))
        threadCLen = len($threadC)
      while true:
        let ev = events.recv()
        case ev.kind
        of evkProgress:
          let
            dx = (ev.thread mod 4) * threadBarWidth
            dy = int(ceil(threadC / 4 - float(ev.thread / 4)))
          cursorAt(dx, dy):
            stdout.styledWrite(
              styleDim,
              align($(ev.thread + 1), threadCLen), " ",
              resetStyle, "[",
              styleBright, if ev.progress < 0.99: fgWhite else: fgGreen,
              progressBar(threadBarWidth - threadCLen - 4, ev.progress),
              resetStyle, "]")
        of evkFinished:
          pi += ev.result
          inc(finishedThreads)
          if finishedThreads == threadC:
            close(events)
            break
      pi *= 4
      result = epochTime() - startTime
      for n in 0..<int(threadC / 4):
        stdout.cursorUp()
        stdout.eraseLine()
      styledEcho(
        styleBright, fgGreen, "✓ finished! ",
        fgWhite, "π ≈ ", fgYellow, $pi)
      stdout.showCursor()
  else:
    quit("thread count must be higher than 0", -1)

addQuitProc() do:
  stdout.showCursor()
  stdout.resetAttributes()

when isMainModule:
  var
    opt = initOptParser()
    digits = 10
    threadC = countProcessors()
  for kind, key, val in opt.getopt():
    case kind
    of cmdShortOption, cmdLongOption:
      case key
      of "d", "digits": digits = parseInt(val)
      of "t", "threads": threadC = parseInt(val)
      else: discard
    else: discard
  styledEcho(styleBright, fgCyan, "❱ pibench2 by iLiquid")
  styledEcho(styleBright,
    "▹ computing ", $digits, " digits of π on ", $threadC, " threads")
  let time = benchmark(threadC, digits)
  styledEcho(
    styleBright, fgGreen, "· took ",
    fgWhite, formatFloat(time, ffDecimal, 4), " s")

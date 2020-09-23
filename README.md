# roulette-bot
An AutoIt bot that plays roulette in the browser by controlling the mouse. (2015)

Someone asked me if it was possible to write a bot that would play roulette in the browser.  
**tl;dr** I tried. I succeeded. It made €100 in 30 minutes. Eventually it lost money. ~~Because it's still roulette...~~

The bot was designed for a game of roulette in the browser on a specific platform. It uses image search to recognize a win state. The way this works is as follows: The game displays a `You won` message whenever you won a round. I cropped this message once and saved it as a small image. At the right moment, after a spin, the bot would search for that image on screen. For this image search I used another AutoIt script called `ImageSearch.au3` which in turn calls `ImageSearchDLL.dll`. These two files were not written by me.

## The algorithm
I did not come up with the strategy myself. It was described to me and I implemented it as requested.

```python
# PSEUDO CODE
win = False
color = black
maxDouble = 6
double = 0
maxTurn = 2
turn = 0
clicks = 1

while true:
  double = 0                                   # reset bet to lowest
  base_bet(clicks)                             # bet lowest
  check_if_win()                               # set boolean
  while not win and double != maxDouble:
    if turn == maxTurn:                        # play twice per color
      color = red if color == black else black # change color
    clear_bet()                                # start fresh
    clicks += pow(2, double)                   # determine nr of clicks required
    double_bet(clicks)                         # bet double of previous amount
    double += 1
```

While working on the code I learned that this uses the [Martingale](https://en.wikipedia.org/wiki/Martingale_(betting_system)) [strategy](https://www.roulettesites.org/strategies/martingale/).  
Everytime you lose, you double your previous bet. More on this later.

## The numbers
| No. of times doubled | No. of clicks        | Bet amount              |
|:---------------------|---------------------:|------------------------:|
|  `0`                 |                  `1` | `  1` × € 0.50 = € 0.50 |
|  `1`                 |  `1` + 2^`0` = `  2` | `  2` × € 0.50 = € 1.00 |
|  `2`                 |  `2` + 2^`1` = `  4` | `  4` × € 0.50 = € 2.00 |
|  `3`                 |  `4` + 2^`2` = `  8` | `  8` × € 0.50 = € 4.00 |
|  `4`                 |  `8` + 2^`3` = ` 16` | ` 16` × € 0.50 = € 8.00 |
|  `5`                 | `16` + 2^`4` = ` 32` | ` 32` × € 0.50 = €16.00 |
|  `6`                 | `32` + 2^`5` = ` 64` | ` 64` × € 0.50 = €32.00 |

_As I format this table I realize that_ **No. of clicks** = `2^(No. of times doubled + 1)`.

## The mistake
This is a screenshot of the routlette table the bot was designed for:  
![alt text](/dev_screen.png "Roulette Table")
_If you look on the right, it clearly says €0.10 MIN and €50 MAX._

* The maximum bet in this particular game was €50.  
* In the table above the bet becomes €32 after doubling 6 times.  

Note: The 1st doubling is the 2nd bet. So, the **6th** doubling is the **7th** bet.  
Therefore, it would make sense that I would limit the number of doublings to 6: `no_of_doublings < 7`.  
Or I could limit the number of consecutive bets to 7: `no_of_bets < 8`.

At the time I probably mixed up the number of doublings with the number of consecutive bets and wrote the following lines (as can be seen in the source code):
```AutoIt
Global $MAXDOUBLE = 8     ; max number of raises
...
While Not $win And $double <> $MAXDOUBLE
```
This allowed the bot to raise a 7th time which resulted in a bet of €50. 

### Why does this matter - this bet of €50?
If a 7th raise was done, that means the bot lost 7 times in a row.  
This amounts to a loss of `0.50 + 1.00 + 2.00 + 4.00 + 8.00 + 16.00 + 32.00 = €63.50`.  

If the bot was able to bet `€64` and win, it would mean a profit of `128 - 64.00 - 63.50 = €0.50`.  
_However_ the bot was only able to bet `€50`. Which meant that even a win would result in `100 - 50.00 - 63.50 = -€13.50`.

This mistake guaranteed a loss of at least `€13.50`. Oops.  
Though the odds of this happening are `(19/37)^7 = 0.0094159282 = 0.94%`.

## The fix
The code should be:
```AutoIt
Global $MAXDOUBLE = 6     ; max number of raises
...
While Not $win And $double <= $MAXDOUBLE
```

---
-- helpers for Speckles
---

--
-- General Controls:
-- Encoder 1 - Volume
-- Button 1 - Standard norns
-- function
-- Button 2 - Change Page

function drawInstructions ()
  screen.move(1, 8)
  screen.text("CONTROLS")
  screen.stroke()
  screen.close()
  
  screen.move(1, 18)
  screen.text("E1 - Volume")
  screen.stroke()
  screen.close()
  
  screen.move(1, 28)
  screen.text("B2 - Change Page")
  screen.stroke()
  screen.close()
  
  screen.move(1, 38)
  screen.text("B3, E2, E3 Page dependant")
  screen.stroke()
  screen.close()
end
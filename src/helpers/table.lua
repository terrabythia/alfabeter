function table.shuffle(t)
  local n = #t -- gets the length of the table 
  while n > 2 do -- only run if the table has more than 1 element
    local k = math.random(n) -- get a random number
    t[n], t[k] = t[k], t[n]
    n = n - 1
 end
 return t
end

function table.key_for_value(t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end

function table.contains(table, element)

  for i = 1, #table do
    if table[i] == element then
      return true
    end
  end
  return false

end

function table.indexOf(table, element)

  for i = 1, #table do
    if table[i] == element then
      return i
    end
  end
  return -1

end

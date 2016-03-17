--------------------
-- fraction.lua
--------------------
-- 分数オブジェクトのパッケージ
-- 使い方は下記「Class Fraction」を参照
-- 負の分数もサポート
--------------------
-- functions
--------------------
-- gcm (greatest common measure) 最大公約数
-- a>0, b>0と仮定する。Luaでは、このとき%の余りは常に非負となる。
local gcm
gcm = function (a,b)
  local r = a % b
  if r == 0 then
    return b
  else
    return gcm(b,r)
  end
end

-- reduce a/bを約分する
local reduce
reduce = function(a,b)
  local a1, b1, sign
  if a>=0 and b>0 then
    a1=a; b1=b; sign=1
  elseif a>=0 and b<0 then
    a1=a; b1=-b; sign=-1
  elseif a<=0 and b>0 then
    a1=-a; b1=b; sign=-1
  elseif a<=0 and b<0 then
    a1=-a; b1=-b; sign=1
  end
  local g = gcm(a1,b1)
-- 分母は正とする。符号は分子で表す。
  return sign*a1//g, b1//g
end

-- multiply 乗算 a/b * c/d
local multiply
multiply = function(a,b,c,d)
  a,b = reduce(a,b)
  c,d = reduce(c,d)
  a,d = reduce(a,d)
  b,c = reduce(b,c)
  return a*c, b*d
end

-- divide 除算 a/b / c/d
local divide
divide = function(a,b,c,d)
  return multiply(a,b,d,c)
end

-- add 加算 a/b + c/d
local add
add = function(a,b,c,d)
  a,b = reduce(a,b)
  c,d = reduce(c,d)
  local g = gcm(b,d)
  return reduce(a*(d//g)+c*(b//g), b*(d//g))
end

-- subtract 減算 a/b - c/d
local subtract
subtract = function(a,b,c,d)
  a,b = reduce(a,b)
  c,d = reduce(c,d)
  local g = gcm(b,d)
  return reduce(a*(d//g)-c*(b//g), b*(d//g))
end

-- tostr 文字列変換
local tostr
tostr = function(a,b)
  if b == 1 then
    return string.format("%d", a)
  else
    return string.format("%d/%d", a, b)
  end
end

-------------------------------
-- Class Fraction
-------------------------------
-- Usage
--   f = Fraction.new(1,2) -->> f = 1/2
--   g = Fraction.new(1,3) -->> g = 1/3
--   h = f + g  -->> h = 1/2 + 1/3 = 5/6 この他の四則もOK
--   h.tostr()  -->> 文字列"5/6"に変換される
--   h.show() -->> 1/2 (is shown)
--   f.set(2,3) -->> 分数fを2/3にセット
--   a,b = f.get() -->> a=2, b=3 になる。fの分子分母のゲット
-------------------------------

local Fraction = {}

Fraction.new = function(a,b)
  local numerator, denominator = reduce(a, b)
  local f = {}
  f.set = function(a1, b1) numerator, denominator = reduce(a1, b1) end
  f.get = function() return numerator, denominator end
  f.tostr = function() return tostr(numerator, denominator) end
  f.show = function() io.write(f.tostr().."\n") end
  setmetatable(f, Fraction)
  return f
end

local t = {__add = add, __sub = subtract, __mul = multiply, __div = divide}
local f_n, f_d, g_n, g_d
for k,v in pairs(t) do
  Fraction[k] = function(f, g)
    f_n, f_d = f.get()
    g_n, g_d = g.get()
    return Fraction.new(v(f_n, f_d, g_n, g_d))
  end
end

return Fraction

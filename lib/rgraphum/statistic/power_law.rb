module Rgraphum::Statistic
  class PowerLaw
  end

  def power_low_rand(max,min,exponent)
    ( (max^exponent-min^exponent)*rand() + min^exponent )^( 1.0/exponent )
  end
end


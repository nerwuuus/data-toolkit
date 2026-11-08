# ============================================================================
# This is how you work out whether if a particular year is a leap year. 
# - on every year that is divisible by 4 with no remainder
# - except every year that is evenly divisible by 100 with no remainder 
# - unless the year is also divisible by 400 with no remainder   
# ============================================================================
def is_leap_year(year):
    
    if year % 4 == 0 and year % 100 > 0:
        return True
    elif year % 4 > 0:
        return False
    else:
        
        if year % 400 == 0:
            return True
        else:
            return False

is_leap_year(2000)
    

/*
 * math.qc
 *
 * Author: Joshua Skelton joshua.skelton@gmail.com
 *
 * A collection of helpful math functions.
 */

float mathlib_accuracy;

// Forward declarations
float(float value, float minValue, float maxValue) clamp;
float(float a, float b) mod;
float(float x) sign;
float(float value, float minValue, float maxValue) wrap;



vector(float x, float y, float z) Vector =
{
    local vector swiz;
    swiz_x = x;
    swiz_y = y;
    swiz_z = z;
    return swiz;
}

/*
 * clamp
 *
 * Limits the given value to the given range.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
float(float value, float minValue, float maxValue) clamp = {
    if (value < minValue) {
        return minValue;
    }
    else if (value > maxValue) {
        return maxValue;
    }

    return value;
};

/*
 * mod
 *
 * Returns the remainder after the division of a by n
 *
 * a: The dividend
 *
 * b: The divisor
 *
 * Returns: The remainder of a divided by n
 */
float(float a, float n) mod = {
    return a - (n * floor(a / n));
};

/*
 * sign
 *
 * Returns an indication of the sign of the given number.
 *
 * x: A number
 *
 * Returns: -1 if x < 0, 0 if x == 0, 1 if x > 0.
 */
float(float x) sign = {
    if (x > 0) {
        return 1;
    }
    else if (x < 0) {
        return -1;
    }

    return 0;
};

/*
 * wrap
 *
 * Limits the given value to the given range and will wrap the value to the
 * the other end of the range if exceeded.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
float(float value, float minValue, float maxValue) wrap = {
    local float range = maxValue - minValue;

    return mod(value - minValue, range + 1) + minValue;
};

float(float a, float b) min = { if (a <= b) return a; return b; }
float(float a, float b) max = { if (a >= b) return a; return b; }

float(float a, float b) xor = { return (a | b) - (a & b); }
float(float a, float b) not = { return a - (a & b); }



//faster version of id's anglemod
float(float v) anglemod =
{
    return v - floor(v/360) * 360;
}

float(float anga, float angb) angledif =
{
    float dif;
    dif = fabs(anga - angb);
    if (dif > 180)
        dif = 360 - dif;
    return dif;
}

// mathlib_sqrt
float(float num) sqrt =
{
    local float apr;

    if(mathlib_accuracy <= 0)
        mathlib_accuracy = 0.001;   //this sets a level of accuracy, it's a global float

    if (num < mathlib_accuracy)
        return 0;
    if (num>1)
        apr = num;
    else
        apr = 1;
    do
    {
        apr = (num + (apr * apr)) / (2 * apr);
    }
    while (fabs((apr * apr) - num) > (num * mathlib_accuracy));
    return apr;
}



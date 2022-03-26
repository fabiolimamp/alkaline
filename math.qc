/*
 * math.qc
 *
 * Author: Joshua Skelton joshua.skelton@gmail.com
 *
 * A collection of helpful math functions.
 */

float mathlib_accuracy;

float M_PI = 3.14159265;

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

vector(float num) SinCos =
{
    local vector angle, vf, vu, vr, result;
    
    vf = v_forward;
    vu = v_up;
    vr = v_right;
    
    angle = '0 1 0' * num;
    makevectors(angle);
    result = Vector(v_forward_y, v_forward_x, v_forward_x / v_forward_y);   // technically SinCosTan
    
    v_forward = vf;
    v_up = vu;
    v_right = vr;
    
    return result;
}

float(float num) sin =
{
    vector temp;
    temp = SinCos(num);
    return temp_x;
}

float(float num) cos =
{
    vector temp;
    temp = SinCos(num);
    return temp_y;
}

float(float num) tan =
{
    vector temp;
    temp = SinCos(num);
    return temp_x / temp_y;
}
 
float(float y, float x) atan2 =
{
    local vector ang; //temporary used to calculate trig values
    ang = '0 0 0';
    ang_x = x;
    ang_y = y;
    return vectoyaw(ang);
}

vector(vector v) vabs =
{
    return Vector(fabs(v_x),fabs(v_y),fabs(v_z));
}


vector(vector a, vector b) vec_scale =
{
    return Vector(a_x * b_x, a_y * b_y, a_z * b_z);
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
    if (value > maxValue) {
        return maxValue;
    }
    else if (value < minValue) {
        return minValue;
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

float(float v) anglemod180 =
{
    return v - floor((v+180)/360) * 360;
}

float(float anga, float angb) angledif =
{
    float dif;
    dif = fabs(anga - angb);
    if (dif > 180)
        dif = 360 - dif;
    return dif;
}

vector(vector anga, vector angb) anglesdif =
{
    vector dif;
    dif = anga - angb;
    if (dif_x > 180)
        dif_x = 360 - dif_x;
    if (dif_y > 180)
        dif_y = 360 - dif_y;
    if (dif_z > 180)
        dif_z = 360 - dif_z;
    return dif;
}

float(vector ang, vector base_ang, vector offset) isInAngle = {
    if (angledif(ang_x, base_ang_x) > offset_x || angledif(ang_y, base_ang_y) > offset_y)
        return FALSE;
    else
        return TRUE;
};


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


float(float a, float b, float mix) lerp =
{
    if (mix <= 0) return a;
    if (mix >= 1) return b;
    return (b * mix + a * ( 1 - mix ) );
}

vector(vector a, vector b, float mix) lerpVector =
{
    if (mix <= 0) return a;
    if (mix >= 1) return b;
    return (b * mix + a * ( 1 - mix ) );
}

// for a relaxing lerp: hermite lerp.
float(float a, float b, float mix) lerpHermite =
{
    if (mix <= 0) return a;
    if (mix >= 1) return b;
    
    local float h01;
    
    h01 = mix * mix;
    h01 *= 3 - 2 * mix;
    
    return (b * h01 + a * ( 1 - h01 ) );
}

vector(vector a, vector b, float mix) lerpVectorHermite =
{
    if (mix <= 0) return a;
    if (mix >= 1) return b;

    local float h01;
    
    h01 = mix * mix;
    h01 *= 3 - 2 * mix;
    
    return (b * h01 + a * ( 1 - h01 ) );
}

// even more smooth:
float(float a, float b, float mix) lerpCosine =
{
    if (mix <= 0) return a;
    if (mix >= 1) return b;
    
    local float cmx;
    cmx = (1 - cos(mix * 180)) / 2;
    
    return (b * cmx + a * ( 1 - cmx ) );
}

vector(vector a, vector b, float mix) lerpVectorCosine =
{
    if (mix <= 0) return a;
    if (mix >= 1) return b;

    local float cmx;
    cmx = (1 - cos(mix * 180)) / 2;
    
    return (b * cmx + a * ( 1 - cmx ) );
}


float() crandom = {
    return 2*(random() - 0.5);
};

//Supa's random offset function
vector(float offset_amt) RandomOffset =
{
    local vector offset;

    offset_x = crandom() * offset_amt;
    offset_y = crandom() * offset_amt;
    offset_z = crandom() * offset_amt;
    
    return offset;
};


// normalizes an angle vector to the 0/+359 range
vector(vector ang) normalizeAngles = {

	ang_x = ang_x - floor(ang_x/360) * 360;
	ang_y = ang_y - floor(ang_y/360) * 360;
	ang_z = ang_z - floor(ang_z/360) * 360;

	/*
	while (ang_x > 360)
		ang_x = ang_x - 360;

	while (ang_x < 0)
		ang_x = ang_x + 360;

	while (ang_y > 360)
		ang_y = ang_y - 360;

	while (ang_y < 0)
		ang_y = ang_y + 360;

	while (ang_z > 360)
		ang_z = ang_z - 360;

	while (ang_z < 0)
		ang_z = ang_z + 360;
	*/
	return ang;
};

// normalizes an angle vector to the -180/+179 range
vector(vector ang) normalizeAngles180 = {
	ang_x = ang_x - floor((ang_x+180)/360) * 360;
	ang_y = ang_y - floor((ang_y+180)/360) * 360;
	ang_z = ang_z - floor((ang_z+180)/360) * 360;

	/*
	while (ang_x > 180)
		ang_x = ang_x - 360;

	while (ang_x < -180)
		ang_x = ang_x + 360;

	while (ang_y > 180)
		ang_y = ang_y - 360;

	while (ang_y < -180)
		ang_y = ang_y + 360;

	while (ang_z > 180)
		ang_z = ang_z - 360;

	while (ang_z < -180)
		ang_z = ang_z + 360;
	*/
	return ang;
};
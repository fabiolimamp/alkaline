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

float(float base, float pw) pow = {
	float ret = 1;
	while (pw > 0) {
		ret *= base;
		pw--;
	}
	return ret;
}

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
	result = [v_forward_y, v_forward_x, v_forward_y / v_forward_x];   // technically SinCosTan

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

float(float x) acos {
	float negate;

	if (x < 0) negate = 1;
	else negate = 0;
	
	x = fabs(x);
	float ret = -0.0187293;
	ret = ret * x;
	ret = ret + 0.0742610;
	ret = ret * x;
	ret = ret - 0.2121144;
	ret = ret * x;
	ret = ret + 1.5707288;
	ret = ret * sqrt(1.0-x);
	ret = ret - 2 * negate * ret;
	return (negate * 3.14159265358979 + ret)/3.14159265358979 * 180;
}

float(float x) acos2 = {
	float a = sqrt(2+2*x);
	float b = sqrt(2-2*x);
	float c = sqrt(2-a);
	return fabs((8/3*c-b/3)/3.14159265358979 * 180);
}


vector(vector v) vabs =
{
	return [fabs(v_x),fabs(v_y),fabs(v_z)];
}


vector(vector a, vector b) vec_scale =
{
	return [a_x * b_x, a_y * b_y, a_z * b_z];
}

vector(vector a, vector b) cross_product = {
	vector ret;
	ret_x = a_y*b_z - a_z*b_y;
	ret_y = a_z*b_x - a_x*b_z;
	ret_z = a_x*b_y - a_y*b_x;
	return ret;
}

vector(vector start, vector start_ctrl, vector end_ctrl, vector end, float u) bezierCurve = {
	vector dest;

	float a = (1-u)*(1-u)*(1-u);
	float b = 3*u*(1-u)*(1-u);
	float c = 3*u*u*(1-u);
	float d = u*u*u;

	dest_x = a*start_x + b*start_ctrl_x + c*end_ctrl_x + d*end_x;
	dest_y = a*start_y + b*start_ctrl_y + c*end_ctrl_y + d*end_y;
	dest_z = a*start_z + b*start_ctrl_z + c*end_ctrl_z + d*end_z;

	return dest;
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
	if (angledif(ang_x, anglemod180(base_ang_x)) > offset_x || angledif(ang_y, anglemod180(base_ang_y)) > offset_y)
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


float(float x) logn {
	return log2(x) * 0.6931472;
	/*
	if (x <= 1 && x > 0)
		return -8.6731532 + (129.946172 + (-558.971892 + (843.967330 - 409.109529*x)*x)*x)*x; // this one is bad
	else if (x > 1 && x <= 2)
		return -1.7417939 + (2.8212026 + (-1.4699568 + (0.44717955 - 0.056570851 * x) * x) * x) * x;
	else
		return 0;
	*/
}


float(float x) log2 {

	if (x > 0 && x <= 1)
		return (-5.83261 - 16.7012*x + 22.394*x*x)/(1 + 11.2638*x + 7.81124*x*x);
	else if (x > 1 && x <= 2)
		return -0.344845*x*x + 2.024658*x -1.674873;
	else
		return 0;
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

float(float runs) weighted_random = {
    float ret = 0;
    
    for (float i = 0; i < runs; i++) {
        ret += random() * 1/runs;
    }
    return ret;
}

float(float runs) weighted_crandom = {
    float ret = 0;
    for (float i = 0; i < runs; i++) {
        ret += random() * 1/runs;
    }
    return 2*(ret - 0.5);
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



// Approximates atan(x) normalized to the [-1,1] range
// with a maximum error of 0.1620 degrees.

float(float x) normalized_atan = {
    float b = 0.596227;

    // Extract the sign bit
    float ux_s = x < 0 ? -1 : 1;

    // Calculate the arctangent in the first quadrant
    float bx_a = fabs(b * x);
    float num = bx_a + x * x;
    float atan_1q = num / (1 + bx_a + num);

    // Restore the sign bit
    float atan_2q = atan_1q * ux_s;
    return atan_2q;
}


// Approximates atan2(y, x) normalized to the [0,4) range
// with a maximum error of 0.1620 degrees

float(float y, float x) normalized_atan2 = {
    float b = 0.596227;

    // Extract the sign bits
    float ux_s  =  x < 0 ? -1 : 1;
    float uy_s  =  y < 0 ? -1 : 1;

    // Determine the quadrant offset
    //float q = (float)( ( ~ux_s & uy_s ) >> 29 | ux_s >> 30 ); 
    float q;
    if (ux_s > 0 && uy_s > 0) q = 0;
    else if (ux_s < 0 && uy_s > 0) q = 1;
    else if (ux_s < 0 && uy_s < 0) q = 2;
    else q = 3;

    // Calculate the arctangent in the first quadrant
    float bxy_a = fabs( b * x * y );
    float num = bxy_a + y * y;
    float atan_1q =  num / ( x * x + bxy_a + num );

    // Translate it to the proper quadrant
    //float uatan_2q = (ux_s ^ uy_s) | (uint32_t &)atan_1q;
    float uatan_2q = ux_s < 0 ? 1 - atan_1q : atan_1q;

    return (q + uatan_2q);
}



// high precision vectoyaw/atan2
// (bxy + y^2) / (x^2 + 2bxy + y^2)
// b = 0.596227
float(vector vec) vectoyaw2 = {
    float b = 0.596227;

    // Extract the sign bits
    float ux_s  =  vec_x < 0 ? -1 : 1;
    float uy_s  =  vec_y < 0 ? -1 : 1;

    // Determine the quadrant offset
    float q;
    if (ux_s >= 0 && uy_s >= 0) q = 0;
    else if (ux_s < 0 && uy_s >= 0) q = 1;
    else if (ux_s < 0 && uy_s < 0) q = 2;
    else q = 3;

    // Calculate the arctangent in the first quadrant
    float bxy_a = fabs( b * vec_x * vec_y );
    float num = bxy_a + vec_y * vec_y;
    float atan_1q =  num / ( vec_x * vec_x + bxy_a + num );

    // Translate it to the proper quadrant
    float uatan_2q = ux_s < 0 ? 1 - atan_1q : atan_1q;
    if (q >= 2) uatan_2q = 1 - uatan_2q;
    return (q + uatan_2q) * 90;
}

// high precision vectoangles
vector(vector vec) vectoangles2 = {
	float yaw, forward, pitch;
	
	if (vec_x == 0 && vec_y == 0)
	{
		yaw = 0;
		if (vec_z > 0) pitch = 90;
		else pitch = 270;
	}
	else {
		yaw = vectoyaw2(vec);
		forward = vlen([vec_x, vec_y, 0]);
		pitch = vectoyaw2([forward, vec_z, 0]);
	}
	return [pitch, yaw, 0];
}


inline void(vector vec) makevectors_angles = {
	makevectors([-vec_x, vec_y, vec_z]);
}

// rotates B around A
vector(vector b, vector a, float r) rotateVectorAround =
{
	float sin, cos, dot;
	vector cross, temp;
	
	cross = cross_product(a, b);
	dot = a*b;
	
	temp = SinCos(r);
	sin = temp_x;
	cos = temp_y;
	
	return b*cos + cross*sin + a*dot*(1-cos);
}
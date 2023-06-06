#version 330 compatibility



/*
 _______ _________ _______  _______  _ 
(  ____ \\__   __/(  ___  )(  ____ )( )
| (    \/   ) (   | (   ) || (    )|| |
| (_____    | |   | |   | || (____)|| |
(_____  )   | |   | |   | ||  _____)| |
      ) |   | |   | |   | || (      (_)
/\____) |   | |   | (___) || )       _ 
\_______)   )_(   (_______)|/       (_)

Do not modify this code until you have read the LICENSE.txt contained in the root directory of this shaderpack!

*/

/////////ADJUSTABLE VARIABLES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////ADJUSTABLE VARIABLES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//#define HALF_RES_TRACE

/////////INTERNAL VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////INTERNAL VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Do not change the name of these variables or their type. The Shaders Mod reads these lines and determines values to send to the inner-workings
//of the shaders mod. The shaders mod only reads these lines and doesn't actually know the real value assigned to these variables in GLSL.
//Some of these variables are critical for proper operation. Change at your own risk.

const bool colortex4Clear = false;
const bool colortex5Clear = false;
//END OF INTERNAL VARIABLES//




in vec4 texcoord;

in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSkyUp;
in vec3 colorTorchlight;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;


in vec3 worldLightVector;
in vec3 worldSunVector;


in mat4 gbufferPreviousModelViewInverse;
in mat4 gbufferPreviousProjectionInverse;


#include "lib/Uniforms.inc"
#include "lib/Common.inc"

#include "lib/Materials.inc"


/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






// vec4 GetViewPosition(in vec2 coord, in float depth) 
// {	
// 	vec2 tcoord = coord;
// 	TemporalJitterProjPosInv01(tcoord);

// 	vec4 fragposition = gbufferProjectionInverse * vec4(tcoord.s * 2.0f - 1.0f, tcoord.t * 2.0f - 1.0f, 2.0f * depth - 1.0f, 1.0f);
// 		 fragposition /= fragposition.w;

	
// 	return fragposition;
// }




vec2 GetNearFragment(vec2 coord, float depth, out float minDepth)
{
	
	
	vec2 texel = 1.0 / vec2(viewWidth, viewHeight);
	vec4 depthSamples;
	depthSamples.x = texture2D(depthtex1, coord + texel * vec2(1.0, 1.0)).x;
	depthSamples.y = texture2D(depthtex1, coord + texel * vec2(1.0, -1.0)).x;
	depthSamples.z = texture2D(depthtex1, coord + texel * vec2(-1.0, 1.0)).x;
	depthSamples.w = texture2D(depthtex1, coord + texel * vec2(-1.0, -1.0)).x;

	vec2 targetFragment = vec2(0.0, 0.0);

	if (depthSamples.x < depth)
		targetFragment = vec2(1.0, 1.0);
	if (depthSamples.y < depth)
		targetFragment = vec2(1.0, -1.0);
	if (depthSamples.z < depth)
		targetFragment = vec2(-1.0, 1.0);
	if (depthSamples.w < depth)
		targetFragment = vec2(-1.0, -1.0);


	minDepth = min(min(min(depthSamples.x, depthSamples.y), depthSamples.z), depthSamples.w);

	return coord + texel * targetFragment;
}










#include "lib/GBufferData.inc"





 int f(float v)
 {
   return int(floor(v));
 }
 int t(int v)
 {
   return v-f(mod(float(v),2.))-0;
 }
 int d(int v)
 {
   return v-f(mod(float(v),2.))-1;
 }
 int d()
 {
   ivec2 v=ivec2(viewWidth,viewHeight);
   int y=v.x*v.y;
   return t(f(floor(pow(float(y),.333333))));
 }
 int f()
 {
   ivec2 v=ivec2(2048,2048);
   int y=v.x*v.y;
   return d(f(floor(pow(float(y),.333333))));
 }
 vec3 v(vec2 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=f.x*f.y,y=d();
   ivec2 i=ivec2(v.x*f.x,v.y*f.y);
   float z=float(i.y/y),r=float(int(i.x+mod(f.x*z,y))/y);
   r+=floor(f.x*z/y);
   vec3 m=vec3(0.,0.,r);
   m.x=mod(i.x+mod(f.x*z,y),y);
   m.y=mod(i.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 s(vec3 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int z=d();
   vec3 i=v.xzy*z;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 r;
   r.x=mod(i.x+x*z,f.x);
   float s=i.x+x*z;
   r.y=i.y+floor(s/f.x)*z;
   r+=.5;
   r/=f;
   return r;
 }
 vec3 x(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=f();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float z=float(n.y/y),r=float(int(n.x+mod(m.x*z,y))/y);
   r+=floor(m.x*z/y);
   vec3 s=vec3(0.,0.,r);
   s.x=mod(n.x+mod(m.x*z,y),y);
   s.y=mod(n.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 f;
   f.x=mod(i.x+x*y,m.x);
   float s=i.x+x*y;
   f.y=i.y+floor(s/m.x)*y;
   f+=.5;
   f/=m;
   f.xy*=.5;
   return f;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 s(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 m(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 e(vec3 v)
 {
   int y=d();
   v*=1./y;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 n(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 e()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,y=floor(v-.0001),x=floor(i-.0001);
   return y-x;
 }
 vec3 r(vec3 v)
 {
   vec4 f=vec4(v,1.);
   f=shadowModelView*f;
   f=shadowProjection*f;
   f/=f.w;
   float x=sqrt(f.x*f.x+f.y*f.y),y=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   f.xy*=.95f/y;
   f.z=mix(f.z,.5,.8);
   f=f*.5f+.5f;
   f.xy*=.5;
   f.xy+=.5;
   return f.xyz;
 }
 vec3 d(vec3 v,vec3 f,vec2 i,vec2 z,vec4 m,vec4 s,inout float y,out vec2 r)
 {
   bool x=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   x=!x;
   if(s.x==8||s.x==9||s.x==79||s.x<1.||!x||s.x==20.||s.x==171.||min(abs(f.x),abs(f.z))>.2)
     y=1.;
   if(s.x==50.||s.x==76.)
     {
       y=0.;
       if(f.y<.5)
         y=1.;
     }
   if(s.x==51)
     y=0.;
   if(s.x>255)
     y=0.;
   vec3 a,c;
   if(f.x>.5)
     a=vec3(0.,0.,-1.),c=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       a=vec3(0.,0.,1.),c=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         a=vec3(1.,0.,0.),c=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           a=vec3(1.,0.,0.),c=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             a=vec3(1.,0.,0.),c=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               a=vec3(-1.,0.,0.),c=vec3(0.,-1.,0.);
   r=clamp((i.xy-z.xy)*100000.,vec2(0.),vec2(1.));
   float t=.15,w=.15;
   if(s.x==10.||s.x==11.)
     {
       if(abs(f.y)<.01&&x||f.y>.99)
         t=.1,w=.1,y=0.;
       else
          y=1.;
     }
   if(s.x==51)
     t=.5,w=.1;
   if(s.x==76)
     t=.2,w=.2;
   if(s.x-255.+39.>=103.&&s.x-255.+39.<=113.)
     w=.025,t=.025;
   a=normalize(m.xyz);
   c=normalize(cross(a,f.xyz)*sign(m.w));
   vec3 n=v.xyz+mix(a*t,-a*t,vec3(r.x));
   n.xyz+=mix(c*t,-c*t,vec3(r.y));
   n.xyz-=f.xyz*w;
   return n;
 }struct qconKIZlZt{vec3 pnOlPKItYq;vec3 pnOlPKItYqOrigin;vec3 WsbjjPghQe;vec3 InIGjfhCoM;vec3 aeHOcnbAiW;vec3 zmecwWmFca;};
 qconKIZlZt p(Ray v)
 {
   qconKIZlZt f;
   f.pnOlPKItYq=floor(v.origin);
   f.pnOlPKItYqOrigin=f.pnOlPKItYq;
   f.WsbjjPghQe=abs(vec3(length(v.direction))/(v.direction+1e-07));
   f.InIGjfhCoM=sign(v.direction);
   f.aeHOcnbAiW=(sign(v.direction)*(f.pnOlPKItYq-v.origin)+sign(v.direction)*.5+.5)*f.WsbjjPghQe;
   f.zmecwWmFca=vec3(0.);
   return f;
 }
 void i(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float y)
 {
   float x,z,r,w;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   w=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),w);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,i=(f-v)*.5,s=y-z,r=vec3(0.);
   r+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-i.x),x);
   r+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-i.y),x);
   r+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),s=min(x,y),c=max(x,y);
   vec2 r=max(s.xx,s.yz);
   float z=max(r.x,r.y);
   r=min(c.xx,c.yz);
   float n=min(r.x,r.y);
   i.x=z;
   i.y=n;
   return n>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float y,inout vec3 x)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),i=m.inv_direction*(f+1e-05-m.origin),s=min(i,z),c=max(i,z);
   vec2 r=max(s.xx,s.yz);
   float t=max(r.x,r.y);
   r=min(c.xx,c.yz);
   float n=min(r.x,r.y);
   bool a=n>max(t,0.)&&max(t,0.)<y;
   if(a)
     x=d(v-1e-05,f+1e-05,m.origin+m.direction*t),y=t;
   return a;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 z,int x)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=r(v);
   float t=.5;
   vec3 s=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*t),2).x;
   s*=saturate(dot(f,y));
   {
     vec4 m=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float w=abs(m.x*256.-(v.y+cameraPosition.y)),c=GetCausticsComposite(v,f,w),n=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     s=mix(s,s*c,1.-n);
   }
   s=TintUnderwaterDepth(s);
   return s*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 f,vec3 y,vec3 z,int x)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=m(v),s=r(i+y*.99);
   float t=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*t),3).x;
   c*=saturate(dot(f,y));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*t),3).x;
   vec3 w=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   w*=w;
   c=mix(c,c*w,vec3(1.-n));
   #endif
   return c*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 f,vec3 y,vec3 z,int x)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=r(v);
   float t=.5;
   vec3 s=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*t),2).x;
   s*=saturate(dot(f,y));
   s=TintUnderwaterDepth(s);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*t),3).x;
   vec3 m=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   m*=m;
   s=mix(s,s*m,vec3(1.-n));
   #endif
   return s*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 h(DADTHOtuFY v)
 {
   vec4 f;
   v.lZygmXBJpl=max(vec3(0.),v.lZygmXBJpl);
   f.x=v.GFxtWSLmhV;
   v.lZygmXBJpl=pow(v.lZygmXBJpl,vec3(.125));
   f.y=PackTwo16BitTo32Bit(v.lZygmXBJpl.x,v.TBAojABNgn);
   f.z=PackTwo16BitTo32Bit(v.lZygmXBJpl.y,v.TGVjqUPLfE);
   f.w=PackTwo16BitTo32Bit(v.lZygmXBJpl.z,v.OGZTEviGjn);
   return f;
 }
 DADTHOtuFY w(vec4 v)
 {
   DADTHOtuFY f;
   vec2 s=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),i=UnpackTwo16BitFrom32Bit(v.w);
   f.GFxtWSLmhV=v.x;
   f.TBAojABNgn=s.y;
   f.TGVjqUPLfE=m.y;
   f.OGZTEviGjn=i.y;
   f.lZygmXBJpl=pow(vec3(s.x,m.x,i.x),vec3(8.));
   return f;
 }
 DADTHOtuFY g(vec2 v)
 {
   vec2 y=1./vec2(viewWidth,viewHeight),x=vec2(viewWidth,viewHeight);
   v=(floor(v*x)+.5)*y;
   return w(texture2DLod(colortex5,v,0));
 }
 float e(float v,float y)
 {
   float f=1.;
   #ifdef FULL_RT_REFLECTIONS
   f=clamp(pow(v,.125)+y,0.,1.);
   #else
   f=clamp(v*10.-7.,0.,1.);
   #endif
   return f;
 }
 bool d(vec3 v,float y,Ray f,bool z,inout float x,inout vec3 t)
 {
   bool i=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(z)
     return false;
   if(y>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),f,x,t);
   i=m;
   #else
   if(y<40.)
     return m=d(v,v+vec3(1.,1.,1.),f,x,t),m;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float r=.5;
       if(y==41.)
         r=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,r,1.),f,x,t);
       i=i||m;
     }
   if(y==42.||y>=55.&&y<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),f,x,t),i=i||m;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float r=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         r=0.;
       m=d(v+vec3(0.,r,0.),v+vec3(.5,.5+r,.5),f,x,t);
       i=i||m;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float r=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         r=0.;
       m=d(v+vec3(.5,r,0.),v+vec3(1.,.5+r,.5),f,x,t);
       i=i||m;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float r=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         r=0.;
       m=d(v+vec3(.5,r,.5),v+vec3(1.,.5+r,1.),f,x,t);
       i=i||m;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float r=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         r=0.;
       m=d(v+vec3(0.,r,.5),v+vec3(.5,.5+r,1.),f,x,t);
       i=i||m;
     }
   if(y>=67.&&y<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,f,x,t),i=i||m;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float r=8.,s=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         r=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         s=16.;
       m=d(v+vec3(r,6.,7.)/16.,v+vec3(s,9.,9.)/16.,f,x,t);
       i=i||m;
       m=d(v+vec3(r,12.,7.)/16.,v+vec3(s,15.,9.)/16.,f,x,t);
       i=i||m;
     }
   if(y>=71.&&y<=82.)
     {
       float r=8.,w=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         w=16.;
       if(y>=75.&&y<=82.)
         r=0.;
       m=d(v+vec3(7.,6.,r)/16.,v+vec3(9.,9.,w)/16.,f,x,t);
       i=i||m;
       m=d(v+vec3(7.,12.,r)/16.,v+vec3(9.,15.,w)/16.,f,x,t);
       i=i||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 r=vec3(0),c=vec3(0);
       if(y==83.)
         r=vec3(0,0,0),c=vec3(16,16,3);
       if(y==84.)
         r=vec3(0,0,13),c=vec3(16,16,16);
       if(y==86.)
         r=vec3(0,0,0),c=vec3(3,16,16);
       if(y==85.)
         r=vec3(13,0,0),c=vec3(16,16,16);
       m=d(v+r/16.,v+c/16.,f,x,t);
       i=i||m;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 r=vec3(0.),c=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float s=0.;
           if(y>=91.&&y<=94.)
             s=13.;
           r=vec3(0.,s,0.)/16.;
           c=vec3(16.,s+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float s=13.;
           if(y==97.||y==98.)
             s=0.;
           r=vec3(0.,0.,s)/16.;
           c=vec3(16.,16.,s+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float s=13.;
           if(y==99.||y==100.)
             s=0.;
           r=vec3(s,0.,0.)/16.;
           c=vec3(s+3.,16.,16.)/16.;
         }
       m=d(v+r,v+c,f,x,t);
       i=i||m;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 r=vec3(0.),s=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float n=float(y)-float(103.)+1.;
           s.y=n*2./16.;
         }
       if(y==111.)
         s.y=.0625;
       if(y==112.)
         r=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(y==113.)
         r=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       m=d(v+r,v+s,f,x,t);
       i=i||m;
     }
   #endif
   #endif
   return i;
 }
 vec2 c(inout float v)
 {
   return fract(sin(vec2(v+=.1,v+=.1))*vec2(43758.5,22578.1));
 }
 float G(vec2 v)
 {
   v*=vec2(viewWidth,viewHeight);
   const float y=1.61803,x=1.32472;
   return fract(dot(v,1./vec2(y,x*x)));
 }
 vec3 T(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight))/64.;
   const vec2 f[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   else
      y+=f[int(mod(frameCounter,8.f))]*.5;
   y=(floor(y*64.)+.5)/64.;
   vec3 m=texture2D(noisetex,y).xyz;
   return m;
 }
 vec3 G(vec3 v,vec2 y)
 {
   y=y*.99+.005;
   #if GI_RESPONSIVENESS<1
   #endif
   float f=6.28319*y.x,x=sqrt(y.y);
   vec3 m=normalize(cross(v,vec3(0.,1.,1.))),r=cross(v,m),i=m*cos(f)*x+r*sin(f)*x+v.xyz*sqrt(1.-y.y);
   return i;
 }
 vec3 C(inout float v)
 {
   vec3 y=T(texcoord.xy).xyz;
   y=fract(y+vec3(c(v),c(v).x)*.1);
   y=y*2.-1.;
   y=normalize(y);
   return y;
 }
 vec3 C(vec3 v,vec3 y)
 {
   vec2 f=s(e(m(v)+y+1.+e()));
   vec3 x=g(f).lZygmXBJpl;
   return x;
 }
 vec3 C()
 {
   vec2 y=s(v(texcoord.xy)+e()/d());
   vec3 f=g(y).lZygmXBJpl;
   return f;
 }
 vec3 C(vec3 v,vec3 m,vec3 y,vec3 s,vec3 x,MaterialMask r,float z,vec2 n,float t,out float c)
 {
   float w=fract(frameCounter*.0123456),a=1.;
   #ifdef SUNLIGHT_LEAK_FIX
   if(isEyeInWater<1)
     a=saturate(z*100.);
   #endif
   float e=1.;
   #ifdef CAVE_GI_LEAK_FIX
   if(isEyeInWater<1)
     e=saturate(z*10.);
   #endif
   vec3 l=T(texcoord.xy+vec2(0.,0.)).xyz,h=G(s,l.xy);
   c=10000.;
   vec3 o=h;
   #ifdef GI_SCREEN_SPACE_TRACING
   bool g=false;
   {
     const int D=5;
     float F=.25*-m.z;
     F=mix(F,.8,.5);
     float q=.07*-m.z;
     q=mix(q,1.,.5);
     q=.6;
     vec2 R=texcoord.xy;
     vec3 V=m.xyz,E=normalize((gbufferModelView*vec4(h.xyz,0.)).xyz);
     for(int S=0;S<D;S++)
       {
         float W=float(S),Y=(W+.5+l.z)/float(D),M=F*Y;
         vec3 I=m.xyz+E*M,P=ProjectBack(I),U=GetViewPositionNoJitter(P.xy,GetDepth(P.xy)).xyz;
         float O=length(I)-length(U)-.02;
         if(O>0.&&O<q)
           {
             g=true;
             R=P.xy;
             V=U.xyz;
             break;
           }
       }
     vec3 S=(gbufferModelViewInverse*vec4(V,1.)).xyz;
     S+=Fract01(cameraPosition.xyz+.5)+.5;
     if(g)
       {
         vec3 W=pow(texture2DLod(colortex7,R.xy-n*.5,0).xyz,vec3(2.2));
         W*=1.-saturate(t*1.1);
         return W*100.;
       }
   }
   #endif
   int R=f();
   float W=1./float(R);
   vec3 q=v+y*(.0002*length(v));
   q+=Fract01(cameraPosition.xyz+.5);
   Ray D=MakeRay(f(q,R)*R-vec3(1.,1.,1.),h);
   qconKIZlZt F=p(D);
   vec3 S=vec3(1.),V=vec3(0.);
   float O=0.,M=1.;
   {
     vec4 P=vec4(0.);
     vec3 I=vec3(0.);
     float E=.5;
     for(int Y=0;Y<DIFFUSE_TRACE_LENGTH;Y++)
       {
         I=F.pnOlPKItYq/float(R);
         vec2 U=d(I,R);
         P=texture2DLod(shadowcolor,U,0);
         O=P.w*255.;
         float u=1.-step(.5,abs(O-241.));
         vec3 L=P.xyz;
         V+=L*u*E*.5;
         #ifdef GI_LEAF_TRANSPARENCY
         if(abs(O-36.)<.1)
           {
             if(l.z<pow(.5,M))
               {
                 i(F);
                 E=1.;
                 M+=10.;
                 S*=pow(P.xyz,vec3(.25));
                 continue;
               }
           }
         #endif
         if(O<240.)
           {
             if(d(F.pnOlPKItYq,O,D,Y==0,c,o))
               {
                 break;
               }
           }
         i(F);
         E=1.;
       }
     float Y=0.;
     if(O<1.f||O>254.f)
       {
         vec3 U=D.direction;
         if(isEyeInWater>0)
           U=refract(U,vec3(0.,-1.,0.),1.3333);
         vec3 L=SkyShading(U,worldSunVector,rainStrength);
         L*=saturate(U.y*10.+1.);
         L=DoNightEyeAtNight(L*12.,timeMidnight)*.083333;
         if(length(U)<.1)
           Y=300.;
         vec3 b=L*e*S,u=b;
         #ifdef CLOUDS_IN_GI
         CloudPlane(u,-D.direction,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,b,timeMidnight,false);
         b=mix(b,u,vec3(a*e));
         #endif
         b=TintUnderwaterDepth(b);
         V+=b*.1;
       }
     else
       {
         if(abs(O-31.)<.1)
           V+=.09*S*P.xyz*GI_LIGHT_BLOCK_INTENSITY;
         if(O>=32.&&O<=35.)
           {
             float L=0.;
             if(abs(O-32.)<.1)
               L=max(-o.z,0.);
             if(abs(O-33.)<.1)
               L=max(o.x,0.);
             if(abs(O-34.)<.1)
               L=max(o.z,0.);
             if(abs(O-35.)<.1)
               L=max(-o.x,0.);
             V+=.04*S*L*vec3(2.,.35,.025)*GI_LIGHT_BLOCK_INTENSITY;
           }
         if(O<240.)
           {
             vec3 L=saturate(P.xyz);
             S*=L;
             V+=C(I,o)*S;
             const float U=2.4;
             vec3 b=i(q+D.direction*c-1.,worldLightVector,o,h,R),u=DoNightEyeAtNight(b*S*U*colorSunlight*a*e*12.,timeMidnight)/12.;
             V+=u;
             Y=c;
           }
       }
     if(isEyeInWater>0)
       UnderwaterFog(V,Y,h,colorSkyUp,colorSunlight);
   }
   if(r.grass<.5)
     V/=saturate(dot(s,h))+.01,V*=saturate(dot(y,h));
   return V;
 }
 vec3 G()
 {
   int y=f();
   vec3 s=v(texcoord.xy),m=n(s),x=f(m-vec3(1.,1.,0.),y);
   vec2 r=d(x,y);
   float t=1.;
   #ifdef CAVE_GI_LEAK_FIX
   if(isEyeInWater<1)
     t*=saturate(eyeBrightnessSmooth.y/240.*20.);
   #endif
   float z=1000.;
   z=min(z,texture2DLod(shadowcolor,d(f(m-vec3(0.,0.,0.),y),y)+vec2(.5,.5)/float(4096),0).w);
   z=min(z,texture2DLod(shadowcolor,d(f(m-vec3(0.,0.,0.),y),y)+vec2(-.5,-.5)/float(4096),0).w);
   z=min(z,texture2DLod(shadowcolor,d(f(m-vec3(0.,1.,0.),y),y)+vec2(0.,0.)/float(4096),0).w);
   z=min(z,texture2DLod(shadowcolor,d(f(m-vec3(0.,-1.,0.),y),y)+vec2(0.,0.)/float(4096),0).w);
   float c=texture2DLod(shadowcolor,d(f(m-vec3(0.,0.,0.),y),y),0).w;
   if(z*255.>240.||c*255.<240.)
     return vec3(0.);
   vec3 a=vec3(0.);
   for(int w=0;w<GI_SECONDARY_SAMPLES;w++)
     {
       float O=sin(frameTimeCounter*1.1)+m.x*.11+m.y*.12+m.z*.13+w*.1;
       vec3 h=normalize(rand(vec2(O))*2.-1.);
       h.x+=h.x==h.y||h.x==h.z?.01:0.;
       h.y+=h.y==h.z?.01:0.;
       vec3 U=m+vec3(1.,1.,1.);
       Ray D=MakeRay(f(U,y)*y-vec3(1.,1.,1.),h);
       qconKIZlZt P=p(D);
       vec3 e=vec3(1.);
       float g=1000.;
       for(int V=0;V<1;V++)
         {
           vec4 q=vec4(0.);
           float L=0.;
           vec3 l=vec3(0.);
           float S=.2;
           for(int Y=0;Y<DIFFUSE_TRACE_LENGTH;Y++)
             {
               l=P.pnOlPKItYq/float(y);
               vec2 R=d(l,y);
               q=texture2DLod(shadowcolor,R,0);
               L=q.w*255.;
               float G=1.-step(.5,abs(L-241.));
               vec3 F=q.xyz;
               a+=F*S*G*(Y==0?.5:1.);
               if(L<240.)
                 {
                   break;
                 }
               i(P);
               S=saturate(S*1.3);
             }
           g=distance(P.pnOlPKItYq.xyz,P.pnOlPKItYqOrigin.xyz);
           float Y=0.,R=1.;
           if(abs(P.pnOlPKItYq.x-P.pnOlPKItYqOrigin.x)<2||abs(P.pnOlPKItYq.y-P.pnOlPKItYqOrigin.y)<2||abs(P.pnOlPKItYq.z-P.pnOlPKItYqOrigin.z)<2)
             R=0.;
           if(L<1.f||L>254.f)
             {
               vec3 F=D.direction;
               if(isEyeInWater>0)
                 F=refract(F,vec3(0.,-1.,0.),1.3333);
               vec3 G=SkyShading(F,worldSunVector,rainStrength);
               G*=saturate(F.y*10.+1.);
               G=DoNightEyeAtNight(G*12.,timeMidnight)*.083333;
               if(isEyeInWater>0)
                 ;
               if(length(F)<.1)
                 Y=300.;
               vec3 b=G*t*e,o=b;
               #ifdef CLOUDS_IN_GI
               CloudPlane(o,-D.direction,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,b,timeMidnight,false);
               b=mix(b,o,vec3(t));
               #endif
               b=TintUnderwaterDepth(b);
               a+=b*.1;
             }
           vec3 F=-P.zmecwWmFca*P.InIGjfhCoM;
           if(abs(L-31.)<.1)
             a+=.09*q.xyz*GI_LIGHT_BLOCK_INTENSITY;
           if(L>=32.&&L<=35.)
             {
               float G=0.;
               if(abs(L-32.)<.1)
                 G=max(-F.z,0.);
               if(abs(L-33.)<.1)
                 G=max(F.x,0.);
               if(abs(L-34.)<.1)
                 G=max(F.z,0.);
               if(abs(L-35.)<.1)
                 G=max(-F.x,0.);
               a+=.02*e*G*vec3(2.,.35,.025)*GI_LIGHT_BLOCK_INTENSITY;
             }
           if(L<240.)
             {
               vec3 G=saturate(q.xyz);
               e*=G;
               vec3 o=-(P.zmecwWmFca*P.InIGjfhCoM);
               const float b=2.4;
               vec3 W=f(l,worldLightVector,o,h,y),E=DoNightEyeAtNight(W*b*colorSunlight*R*e*t*12.,timeMidnight)/12.;
               a+=E*2.;
               a+=C(l,o)*e;
               Y=g;
             }
           {
             vec2 G=IntersectSphere(m,D.direction,vec3(0.,1.5,0.),.75);
             if(g>G.y&&G.y>-.5)
               ;
           }
           if(isEyeInWater>0)
             UnderwaterFog(a,Y,h,colorSkyUp,colorSunlight);
         }
     }
   a/=float(GI_SECONDARY_SAMPLES);
   return saturate(a);
 }
 vec4 D(float v)
 {
   float y=v*v,m=y*v;
   vec4 f;
   f.x=-m+3*y-3*v+1;
   f.y=3*m-6*y+4;
   f.z=-3*m+3*y+3*v+1;
   f.w=m;
   return f/6.f;
 }
 vec4 D(in sampler2D v,in vec2 f)
 {
   vec2 y=vec2(viewWidth,viewHeight);
   f*=y;
   f-=.5;
   float m=fract(f.x),s=fract(f.y);
   f.x-=m;
   f.y-=s;
   vec4 i=D(m),r=D(s),x=vec4(f.x-.5,f.x+1.5,f.y-.5,f.y+1.5),c=vec4(i.x+i.y,i.z+i.w,r.x+r.y,r.z+r.w),t=x+vec4(i.y,i.w,r.y,r.w)/c,z=texture2DLod(v,vec2(t.x,t.z)/y,0),a=texture2DLod(v,vec2(t.y,t.z)/y,0),w=texture2DLod(v,vec2(t.x,t.w)/y,0),h=texture2DLod(v,vec2(t.y,t.w)/y,0);
   float n=c.x/(c.x+c.y),o=c.z/(c.z+c.w);
   return mix(mix(h,w,n),mix(a,z,n),o);
 }
 bool T(vec3 v,vec3 y)
 {
   vec3 f=normalize(cross(dFdx(v),dFdy(v))),s=normalize(y-v),x=normalize(s);
   float m=.02+length(v)*.04;
   return distance(v,y)<m;
 }
 vec3 F(vec2 v)
 {
   vec2 y=vec2(viewWidth,viewHeight),m=1./y,s=v*y,x=floor(s-.5)+.5,f=s-x,z=f*f,r=f*z;
   float t=.5;
   vec2 i=-t*r+2.*t*z-t*f,c=(2.-t)*r-(3.-t)*z+1.,w=-(2.-t)*r+(3.-2.*t)*z+t*f,n=t*r-t*z,a=c+w,P=m*(x+w/a);
   vec3 F=texture2DLod(colortex4,vec2(P.x,P.y),0).xyz;
   vec2 o=m*(x-1.),h=m*(x+2.);
   vec4 G=vec4(texture2DLod(colortex4,vec2(P.x,o.y),0).xyz,1.)*(a.x*i.y)+vec4(texture2DLod(colortex4,vec2(o.x,P.y),0).xyz,1.)*(i.x*a.y)+vec4(F,1.)*(a.x*a.y)+vec4(texture2DLod(colortex4,vec2(h.x,P.y),0).xyz,1.)*(n.x*a.y)+vec4(texture2DLod(colortex4,vec2(P.x,h.y),0).xyz,1.)*(a.x*n.y);
   return max(vec3(0.),G.xyz*(1./G.w));
 }
 vec2 C(float v,vec2 f,out float y,out vec3 i,out vec4 s)
 {
   float t;
   vec2 x=GetNearFragment(texcoord.xy,v,t);
   y=texture2D(depthtex1,x).x;
   vec4 m=vec4(texcoord.xy*2.-1.,y*2.-1.,1.),r=gbufferProjectionInverse*m;
   r.xyz/=r.w;
   vec4 z=gbufferModelViewInverse*vec4(r.xyz,1.);
   s=z;
   s.xyz+=cameraPosition-previousCameraPosition;
   vec4 c=gbufferPreviousModelView*vec4(s.xyz,1.),n=gbufferPreviousProjection*vec4(c.xyz,1.);
   n.xyz/=n.w;
   i=m.xyz-n.xyz;
   float a=length(i.xy)*10.,w=clamp(a*500.,0.,1.);
   vec2 G=f.xy-i.xy*.5;
   if(y<.7)
     G=texcoord.xy;
   return G;
 }
 void main()
 {
   GBufferData v=GetGBufferData();
   MaterialMask y=CalculateMasks(v.materialID);
   vec4 f=GetViewPosition(texcoord.xy,v.depth),s=gbufferModelViewInverse*vec4(f.xyz,1.),i=gbufferModelViewInverse*vec4(f.xyz,0.);
   vec3 x=normalize(f.xyz),r=normalize(i.xyz),m=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz),z=normalize((gbufferModelViewInverse*vec4(v.geoNormal,0.)).xyz);
   float c=length(f.xyz),t=dot(v.mcLightmap.xy,vec2(.5));
   if(y.grass>.5)
     m=vec3(0.,1.,0.),z=vec3(0.,1.,0.);
   vec4 n=vec4(texcoord.xy,0.,0.);
   float w;
   vec3 P;
   vec4 a;
   vec2 L=C(v.depth,n.xy,w,P,a),o=L.xy;
   o-=(vec2(mod(frameCounter/2,2.f),mod(frameCounter,2.f))-.5)/vec2(viewWidth,viewHeight)*1.5;
   vec3 Y=F(o.xy);
   DADTHOtuFY R=g(L.xy);
   float O=1./(saturate(-dot(v.geoNormal,x))*100.+1.);
   vec4 l=vec4(L.xy,0.,0.);
   TemporalJitterProjPosPrevInv(l);
   vec4 q=gbufferPreviousProjectionInverse*vec4(L.xy*2.-1.,texture2DLod(colortex7,l.xy,0).w*2.-1.,1.);
   q/=q.w;
   vec3 D=(gbufferPreviousModelViewInverse*vec4(q.xyz,1.)).xyz;
   R.GFxtWSLmhV+=1.;
   R.GFxtWSLmhV=min(R.GFxtWSLmhV,2.);
   vec2 e=1./vec2(viewWidth,viewHeight),d=1.-e;
   float b=0.,U=1.-exp2(-R.GFxtWSLmhV);
   if(!T(a.xyz,D.xyz)||(L.x<e.x||L.x>d.x||L.y<e.y||L.y>d.y)||abs(O-R.TBAojABNgn)>.01)
     U=0.,b=.99,R.GFxtWSLmhV=0.;
   float S;
   vec3 V=C(s.xyz,f.xyz,m.xyz,z,r.xyz,y,v.mcLightmap.y,P.xy,b,S);
   V=max(vec3(0.),V);
   V=mix(V,Y,vec3(U));
   b=max(b,mix(b,.9,saturate(-P.z*120.)));
   R.TBAojABNgn=O;
   R.TGVjqUPLfE=mix(R.TGVjqUPLfE,b,mix(.5,1.,b));
   R.OGZTEviGjn=t;
   vec3 E=G();
   R.lZygmXBJpl=mix(C(),E,vec3(.015));
   vec4 W=h(R);
   gl_FragData[0]=vec4(V,saturate(w));
   gl_FragData[1]=vec4(W);
   gl_FragData[2]=vec4(V,1.);
 };




/* DRAWBUFFERS:456 */

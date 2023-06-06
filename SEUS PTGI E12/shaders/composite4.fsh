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


#include "lib/Uniforms.inc"
#include "lib/Common.inc"


const bool colortex6MipmapEnabled = false;


in vec4 texcoord;

in vec3 lightVector;
in vec3 worldLightVector;
in vec3 worldSunVector;

in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSkyUp;
in vec3 colorTorchlight;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;

#include "lib/GBufferData.inc"


// vec4 GetViewPosition(in vec2 coord, in float depth) 
// {	
// 	vec4 tcoord = vec4(coord.xy, 0.0, 0.0);

// 	vec4 fragposition = gbufferProjectionInverse * vec4(tcoord.s * 2.0f - 1.0f, tcoord.t * 2.0f - 1.0f, 2.0f * depth - 1.0f, 1.0f);
// 		 fragposition /= fragposition.w;

	
// 	return fragposition;
// }





#include "lib/Materials.inc"


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
   int z=v.x*v.y;
   return t(f(floor(pow(float(z),.333333))));
 }
 int f()
 {
   ivec2 v=ivec2(2048,2048);
   int z=v.x*v.y;
   return d(f(floor(pow(float(z),.333333))));
 }
 vec3 e(vec2 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=m.x*m.y,z=d();
   ivec2 f=ivec2(v.x*m.x,v.y*m.y);
   float y=float(f.y/z),i=float(int(f.x+mod(m.x*y,z))/z);
   i+=floor(m.x*y/z);
   vec3 s=vec3(0.,0.,i);
   s.x=mod(f.x+mod(m.x*y,z),z);
   s.y=mod(f.y,z);
   s.xyz=floor(s.xyz);
   s/=z;
   s.xyz=s.xzy;
   return s;
 }
 vec2 x(vec3 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 f=v.xzy*x;
   f=floor(f+1e-05);
   float y=f.z;
   vec2 i;
   i.x=mod(f.x+y*x,m.x);
   float s=f.x+y*x;
   i.y=f.y+floor(s/m.x)*x;
   i+=.5;
   i/=m;
   return i;
 }
 vec3 s(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,z=f();
   ivec2 s=ivec2(i.x*m.x,i.y*m.y);
   float y=float(s.y/z),r=float(int(s.x+mod(m.x*y,z))/z);
   r+=floor(m.x*y/z);
   vec3 n=vec3(0.,0.,r);
   n.x=mod(s.x+mod(m.x*y,z),z);
   n.y=mod(s.y,z);
   n.xyz=floor(n.xyz);
   n/=z;
   n.xyz=n.xzy;
   return n;
 }
 vec2 d(vec3 v,int z)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 f=v.xzy*z;
   f=floor(f+1e-05);
   float x=f.z;
   vec2 i;
   i.x=mod(f.x+x*z,m.x);
   float s=f.x+x*z;
   i.y=f.y+floor(s/m.x)*z;
   i+=.5;
   i/=m;
   i.xy*=.5;
   return i;
 }
 vec3 e(vec3 v,int z)
 {
   return v*=1./z,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 f(vec3 v,int z)
 {
   return v*=1./z,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 n(vec3 v)
 {
   int x=d();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 r(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 e()
 {
   vec3 v=cameraPosition.xyz+.5,f=previousCameraPosition.xyz+.5,z=floor(v-.0001),x=floor(f-.0001);
   return z-x;
 }
 vec3 m(vec3 v)
 {
   vec4 f=vec4(v,1.);
   f=shadowModelView*f;
   f=shadowProjection*f;
   f/=f.w;
   float x=sqrt(f.x*f.x+f.y*f.y),z=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   f.xy*=.95f/z;
   f.z=mix(f.z,.5,.8);
   f=f*.5f+.5f;
   f.xy*=.5;
   f.xy+=.5;
   return f.xyz;
 }
 vec3 d(vec3 v,vec3 f,vec2 s,vec2 z,vec4 m,vec4 i,inout float x,out vec2 n)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(i.x==8||i.x==9||i.x==79||i.x<1.||!r||i.x==20.||i.x==171.||min(abs(f.x),abs(f.z))>.2)
     x=1.;
   if(i.x==50.||i.x==76.)
     {
       x=0.;
       if(f.y<.5)
         x=1.;
     }
   if(i.x==51)
     x=0.;
   if(i.x>255)
     x=0.;
   vec3 y,e;
   if(f.x>.5)
     y=vec3(0.,0.,-1.),e=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       y=vec3(0.,0.,1.),e=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         y=vec3(1.,0.,0.),e=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           y=vec3(1.,0.,0.),e=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             y=vec3(1.,0.,0.),e=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               y=vec3(-1.,0.,0.),e=vec3(0.,-1.,0.);
   n=clamp((s.xy-z.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,c=.15;
   if(i.x==10.||i.x==11.)
     {
       if(abs(f.y)<.01&&r||f.y>.99)
         h=.1,c=.1,x=0.;
       else
          x=1.;
     }
   if(i.x==51)
     h=.5,c=.1;
   if(i.x==76)
     h=.2,c=.2;
   if(i.x-255.+39.>=103.&&i.x-255.+39.<=113.)
     c=.025,h=.025;
   y=normalize(m.xyz);
   e=normalize(cross(y,f.xyz)*sign(m.w));
   vec3 d=v.xyz+mix(y*h,-y*h,vec3(n.x));
   d.xyz+=mix(e*h,-e*h,vec3(n.y));
   d.xyz-=f.xyz*c;
   return d;
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
 void w(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float z)
 {
   float x,y,r,e;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   z=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   y=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   e=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   z=min(min(z,y),e);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 z)
 {
   const float x=1e-05;
   vec3 y=(f+v)*.5,i=(f-v)*.5,s=z-y,r=vec3(0.);
   r+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-i.x),x);
   r+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-i.y),x);
   r+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 z=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),s=min(x,z),n=max(x,z);
   vec2 r=max(s.xx,s.yz);
   float y=max(r.x,r.y);
   r=min(n.xx,n.yz);
   float e=min(r.x,r.y);
   i.x=y;
   i.y=e;
   return e>max(y,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float x,inout vec3 z)
 {
   vec3 y=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(f+1e-05-m.origin),i=min(s,y),n=max(s,y);
   vec2 r=max(i.xx,i.yz);
   float h=max(r.x,r.y);
   r=min(n.xx,n.yz);
   float e=min(r.x,r.y);
   bool t=e>max(h,0.)&&max(h,0.)<x;
   if(t)
     z=d(v-1e-05,f+1e-05,m.origin+m.direction*h),x=h;
   return t;
 }
 vec3 e(vec3 v,vec3 f,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,z));
   {
     vec4 n=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float e=abs(n.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,e),t=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     r=mix(r,r*h,1.-t);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 z,vec3 f,vec3 x,vec3 y,int t)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 s=v(z),i=m(s+x*.99);
   float n=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*n),3).x;
   r*=saturate(dot(f,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float e=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*n),3).x;
   vec3 h=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   h*=h;
   r=mix(r,r*h,vec3(1.-e));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 f,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,z));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-n));
   #endif
   return r*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 h(DADTHOtuFY v)
 {
   vec4 i;
   v.lZygmXBJpl=max(vec3(0.),v.lZygmXBJpl);
   i.x=v.GFxtWSLmhV;
   v.lZygmXBJpl=pow(v.lZygmXBJpl,vec3(.125));
   i.y=PackTwo16BitTo32Bit(v.lZygmXBJpl.x,v.TBAojABNgn);
   i.z=PackTwo16BitTo32Bit(v.lZygmXBJpl.y,v.TGVjqUPLfE);
   i.w=PackTwo16BitTo32Bit(v.lZygmXBJpl.z,v.OGZTEviGjn);
   return i;
 }
 DADTHOtuFY i(vec4 v)
 {
   DADTHOtuFY i;
   vec2 f=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),s=UnpackTwo16BitFrom32Bit(v.w);
   i.GFxtWSLmhV=v.x;
   i.TBAojABNgn=f.y;
   i.TGVjqUPLfE=m.y;
   i.OGZTEviGjn=s.y;
   i.lZygmXBJpl=pow(vec3(f.x,m.x,s.x),vec3(8.));
   return i;
 }
 DADTHOtuFY G(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),z=vec2(viewWidth,viewHeight);
   v=(floor(v*z)+.5)*x;
   return i(texture2DLod(colortex5,v,0));
 }
 float G(float v,float z)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+z,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool G(vec3 v,float z,Ray f,bool y,inout float x,inout vec3 i)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(z>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),f,x,i);
   r=m;
   #else
   if(z<40.)
     return m=d(v,v+vec3(1.,1.,1.),f,x,i),m;
   if(z==40.||z==41.||z>=43.&&z<=54.)
     {
       float s=.5;
       if(z==41.)
         s=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),f,x,i);
       r=r||m;
     }
   if(z==42.||z>=55.&&z<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),f,x,i),r=r||m;
   if(z==43.||z==46.||z==47.||z==52.||z==53.||z==54.||z==55.||z==58.||z==59.||z==64.||z==65.||z==66.)
     {
       float s=.5;
       if(z==55.||z==58.||z==59.||z==64.||z==65.||z==66.)
         s=0.;
       m=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),f,x,i);
       r=r||m;
     }
   if(z==43.||z==45.||z==48.||z==51.||z==53.||z==54.||z==55.||z==57.||z==60.||z==63.||z==65.||z==66.)
     {
       float s=.5;
       if(z==55.||z==57.||z==60.||z==63.||z==65.||z==66.)
         s=0.;
       m=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),f,x,i);
       r=r||m;
     }
   if(z==44.||z==45.||z==49.||z==51.||z==52.||z==54.||z==56.||z==57.||z==61.||z==63.||z==64.||z==66.)
     {
       float s=.5;
       if(z==56.||z==57.||z==61.||z==63.||z==64.||z==66.)
         s=0.;
       m=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),f,x,i);
       r=r||m;
     }
   if(z==44.||z==46.||z==50.||z==51.||z==52.||z==53.||z==56.||z==58.||z==62.||z==63.||z==64.||z==65.)
     {
       float s=.5;
       if(z==56.||z==58.||z==62.||z==63.||z==64.||z==65.)
         s=0.;
       m=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),f,x,i);
       r=r||m;
     }
   if(z>=67.&&z<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,f,x,i),r=r||m;
   if(z==68.||z==69.||z==70.||z==72.||z==73.||z==74.||z==76.||z==77.||z==78.||z==80.||z==81.||z==82.)
     {
       float s=8.,h=8.;
       if(z==68.||z==70.||z==72.||z==74.||z==76.||z==78.||z==80.||z==82.)
         s=0.;
       if(z==69.||z==70.||z==73.||z==74.||z==77.||z==78.||z==81.||z==82.)
         h=16.;
       m=d(v+vec3(s,6.,7.)/16.,v+vec3(h,9.,9.)/16.,f,x,i);
       r=r||m;
       m=d(v+vec3(s,12.,7.)/16.,v+vec3(h,15.,9.)/16.,f,x,i);
       r=r||m;
     }
   if(z>=71.&&z<=82.)
     {
       float s=8.,n=8.;
       if(z>=71.&&z<=74.||z>=79.&&z<=82.)
         n=16.;
       if(z>=75.&&z<=82.)
         s=0.;
       m=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,n)/16.,f,x,i);
       r=r||m;
       m=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,n)/16.,f,x,i);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(z>=83.&&z<=86.)
     {
       vec3 s=vec3(0),e=vec3(0);
       if(z==83.)
         s=vec3(0,0,0),e=vec3(16,16,3);
       if(z==84.)
         s=vec3(0,0,13),e=vec3(16,16,16);
       if(z==86.)
         s=vec3(0,0,0),e=vec3(3,16,16);
       if(z==85.)
         s=vec3(13,0,0),e=vec3(16,16,16);
       m=d(v+s/16.,v+e/16.,f,x,i);
       r=r||m;
     }
   if(z>=87.&&z<=102.)
     {
       vec3 s=vec3(0.),e=vec3(1.);
       if(z>=87.&&z<=94.)
         {
           float h=0.;
           if(z>=91.&&z<=94.)
             h=13.;
           s=vec3(0.,h,0.)/16.;
           e=vec3(16.,h+3.,16.)/16.;
         }
       if(z>=95.&&z<=98.)
         {
           float n=13.;
           if(z==97.||z==98.)
             n=0.;
           s=vec3(0.,0.,n)/16.;
           e=vec3(16.,16.,n+3.)/16.;
         }
       if(z>=99.&&z<=102.)
         {
           float h=13.;
           if(z==99.||z==100.)
             h=0.;
           s=vec3(h,0.,0.)/16.;
           e=vec3(h+3.,16.,16.)/16.;
         }
       m=d(v+s,v+e,f,x,i);
       r=r||m;
     }
   if(z>=103.&&z<=113.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(z>=103.&&z<=110.)
         {
           float e=float(z)-float(103.)+1.;
           n.y=e*2./16.;
         }
       if(z==111.)
         n.y=.0625;
       if(z==112.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(z==113.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       m=d(v+s,v+n,f,x,i);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 float h(float v,float z)
 {
   return 1./(v*(1.-z)+z);
 }
 void G(inout vec3 v,in vec3 z,in vec3 x,vec3 f,float y)
 {
   float r=length(z);
   r*=pow(eyeBrightnessSmooth.y/240.f,6.f);
   r*=rainStrength;
   float s=pow(exp(-r*3e-06),4.);
   vec3 i=vec3(dot(colorSkyUp,vec3(1.)));
   v=mix(i,v,vec3(s));
 }
 vec4 c(vec2 v)
 {
   vec2 z=vec2(v.x,(v.y-floor(mod(FRAME_TIME*60.f,60.f)))/60.f);
   return texture2DLod(colortex4,z.xy,0);
 }
 float c(vec3 v,float z)
 {
   vec3 i=v.xyz+cameraPosition.xyz,f=refract(worldLightVector,vec3(0.,1.,0.),.750188);
   i+=f*((v.y+cameraPosition.y)/f.y);
   vec4 s=c(mod(i.xz/4.,vec2(1.)))*13.;
   float x=pow(z/2.,.5),r=pow(s.x,saturate(x*.5+.5));
   r=mix(r,s.y,saturate(x-1.));
   r=mix(r,s.z,saturate(x-2.));
   r=mix(r,s.w,saturate(x-3.));
   return r;
 }
 float i(float v,float z)
 {
   return exp(-pow(v/(.9*z),2.));
 }
 float m(vec3 v,vec3 z)
 {
   return dot(abs(v-z),vec3(.3333));
 }
 vec3 a(vec2 v)
 {
   vec2 z=vec2(v.xy*vec2(viewWidth,viewHeight))/64.;
   const vec2 f[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   z=(floor(z*64.)+.5)/64.;
   vec3 i=texture2D(noisetex,z).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   i=mod(i+vec3(s)*mod(frameCounter,64.f),vec3(1.));
   return i;
 }
 vec3 G(float v,float f,float x,vec3 z)
 {
   vec3 i;
   i.x=x*cos(v);
   i.y=x*sin(v);
   i.z=f;
   vec3 s=abs(z.y)<.999?vec3(0,0,1):vec3(1,0,0),r=normalize(cross(z,vec3(0.,1.,1.))),e=cross(r,z);
   return r*i.x+e*i.y+z*i.z;
 }
 vec3 G(vec2 v,float z,vec3 i)
 {
   float s=2*3.14159*v.x,x=sqrt((1-v.y)/(1+(z*z-1)*v.y)),f=sqrt(1-x*x);
   return G(s,x,f,i);
 }
 float g(float v)
 {
   return 2./(v*v+1e-07)-2.;
 }
 vec3 a(in vec2 v,in float z,in vec3 i)
 {
   float s=g(z),f=2*3.14159*v.x,x=pow(v.y,1.f/(s+1.f)),r=sqrt(1-x*x);
   return G(f,x,r,i);
 }
 float l(vec2 v)
 {
   return texture2DLod(colortex3,v,0).w;
 }
 float a(float v,float z)
 {
   return v/(z*20.01+1.);
 }
 vec2 g(vec2 v,float z)
 {
   vec2 s=v;
   mat2 x=mat2(cos(z),-sin(z),sin(z),cos(z));
   v=x*v;
   return v;
 }
 vec4 G(sampler2D v,float x,bool z,float f,float s,float i,float y)
 {
   GBufferData r=GetGBufferData();
   GBufferDataTransparent n=GetGBufferDataTransparent();
   bool e=n.depth<r.depth;
   if(e)
     r.normal=n.normal,r.smoothness=n.smoothness,r.metalness=0.,r.mcLightmap=n.mcLightmap,r.depth=n.depth;
   vec4 h=GetViewPosition(texcoord.xy,r.depth),c=gbufferModelViewInverse*vec4(h.xyz,1.),d=gbufferModelViewInverse*vec4(h.xyz,0.);
   vec3 t=normalize(h.xyz),o=normalize(d.xyz),p=normalize((gbufferModelViewInverse*vec4(r.normal,0.)).xyz);
   float w=GetDepthLinear(texcoord.xy),R=dot(-t,r.normal.xyz),T=1.-r.smoothness,D=T*T,b=G(r.smoothness,r.metalness);
   vec4 W=texture2DLod(colortex6,texcoord.xy,0);
   float q=Luminance(W.xyz);
   if(b<.001)
     return W;
   float P=x*.9;
   P*=min(D*20.,1.1);
   P*=mix(W.w,1.,1.);
   vec2 M=vec2(0.);
   if(z)
     {
       vec2 F=BlueNoiseTemporal(texcoord.xy).xy*.99+.005;
       M=F-.5;
     }
   float F=0.,E=1.1,Y=a(f,r.totalTexGrad)/(D+.0001),S=a(s,r.totalTexGrad);
   vec4 V=vec4(0.),u=vec4(0.);
   float U=0.;
   vec4 I=vec4(vec3(i),1.);
   I.xyz=vec3(.5);
   I.xyz*=W.w*.95+.05;
   float O=r.smoothness;
   vec2 L=normalize(cross(r.normal,t).xy),k=g(L,1.5708);
   float A=1.-pow(1.-saturate(R),1.);
   L*=mix(.1675,.5,A);
   k*=mix(mix(.7,.7,D),.5,A);
   vec3 B=reflect(-t,r.normal);
   int H=0;
   for(int j=-1;j<=1;j++)
     {
       for(int Z=-1;Z<=1;Z++)
         {
           vec2 C=vec2(j,Z)+M;
           C=C.x*L+C.y*k;
           C*=P*1.5/vec2(viewWidth,viewHeight);
           vec2 N=texcoord.xy+C.xy;
           float K=length(C*vec2(viewWidth,viewHeight));
           if(K*.025>W.w+.1)
             {
               continue;
             }
           N=clamp(N,4./vec2(viewWidth,viewHeight),1.-4./vec2(viewWidth,viewHeight));
           vec4 X=texture2DLod(colortex6,N,0);
           vec3 J=GetNormals(N);
           float Q=GetDepthLinear(N),ab=pow(saturate(dot(B,reflect(-t,J))),105./D),ac=exp(-(abs(Q-w)*E)),ad=exp(-(m(X.xyz,W.xyz)*F)),ae=exp(-abs(O-l(N))*S),af=ab*ac*ad*ae;
           V+=vec4(pow(length(X.xyz),I.x)*normalize(X.xyz+1e-10),X.w)*af;
           U+=af;
           u+=X;
           H++;
         }
     }
   V/=U+.0001;
   V.xyz=pow(length(V.xyz),1./I.x)*normalize(V.xyz+1e-06);
   vec4 N=V;
   if(U<.001)
     N=W;
   return N;
 }
 void main()
 {
   GBufferData v=GetGBufferData();
   GBufferDataTransparent z=GetGBufferDataTransparent();
   MaterialMask s=CalculateMasks(v.materialID),i=CalculateMasks(z.materialID);
   bool f=z.depth<v.depth;
   if(f)
     v.normal=z.normal,v.smoothness=z.smoothness,v.metalness=0.,v.mcLightmap=z.mcLightmap,v.depth=z.depth,i.sky=0.;
   vec4 r=GetViewPosition(texcoord.xy,v.depth),x=gbufferModelViewInverse*vec4(r.xyz,1.),m=gbufferModelViewInverse*vec4(r.xyz,0.);
   vec3 n=normalize(r.xyz),y=normalize(m.xyz),e=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz);
   float t=ExpToLinearDepth(v.depth),c=1.-v.smoothness,a=c*c,l=G(v.smoothness,v.metalness);
   int w=0;
   vec4 p=texture2DLod(colortex6,texcoord.xy,w),d=p;
   float W=1.-v.smoothness,T=W*W;
   vec3 N=e,D=-y,R=normalize(reflect(-D,N)+N*T),o=normalize(D+R);
   float P=saturate(dot(N,R)),b=saturate(dot(N,D)),Y=saturate(dot(N,o)),A=saturate(dot(R,o)),U=v.metalness*.98+.02,S=pow(1.-A,5.),E=U+(1.-U)*S,F=T/2.,M=h(P,F)*h(b+.8,F),V=P*E*M;
   d.xyz*=mix(vec3(1.),v.albedo.xyz,vec3(v.metalness));
   V=mix(V,1.,v.metalness);
   if(v.depth>.99999)
     V=0.;
   if(i.water>.5&&isEyeInWater>0)
     {
       if(length(refract(D,N,1.3333))<.5)
         V=1.;
       else
          V=0.;
     }
   V*=G(v.smoothness,v.metalness);
   if(i.water>.5&&isEyeInWater==0)
     V=mix(.02,V,.7);
   vec4 X=texture2DLod(colortex3,texcoord.xy,0);
   vec3 C=pow(X.xyz,vec3(2.2)),I=C;
   I*=120.;
   if(isEyeInWater>0)
     UnderwaterFog(I,length(m.xyz),y,colorSkyUp,colorSunlight);
   I=mix(I,d.xyz*12.,vec3(saturate(V)));
   I+=C*v.metalness*120.;
   {
     #ifdef GODRAYS
     #else
     if(isEyeInWater>0)
       #endif
     {
       float q=BlueNoiseTemporal(texcoord.xy).x,L=120.;
       if(isEyeInWater>0)
         L=20.;
       vec3 j=vec3(0.),k=(gbufferModelViewInverse*vec4(0.,0.,0.,1.)).xyz;
       for(int Z=0;Z<10;Z++)
         {
           float O=float(Z+q)/float(10);
           vec3 g=y.xyz*L*O+k;
           if(length(m.xyz)<length(g-k))
             {
               break;
             }
           float B,J;
           vec3 K=WorldPosToShadowProjPos(g.xyz,B,J),u=shadow2DLod(shadowtex0,vec3(K.xy,K.z+1e-06),3).xxx;
           #ifdef GODRAYS_STAINED_GLASS_TINT
           float H=shadow2DLod(shadowtex0,vec3(K.xy-vec2(.5,0.),K.z-1e-06),3).x;
           vec3 Q=texture2DLod(shadowcolor,vec2(K.xy-vec2(.5,0.)),3).xyz;
           Q*=Q;
           u=mix(u,u*Q,vec3(1.-H));
           #endif
           if(isEyeInWater>0)
             {
               float ag=abs(texture2DLod(shadowcolor1,K.xy-vec2(0.,.5),4).x*256.-(g.y+cameraPosition.y)),ah=GetCausticsComposite(g,worldLightVector,ag),ai=shadow2DLod(shadowtex0,vec3(K.xy-vec2(0.,.5),K.z+1e-06),4).x;
               u=mix(u,u*ah,vec3(1.-ai));
               j+=u*exp(-GetWaterAbsorption()*(L*O))*exp(-GetWaterAbsorption()*ag);
             }
           else
              j+=u*colorSunlight*.1;
         }
       float u=dot(worldLightVector,y.xyz),K=1.;
       if(isEyeInWater>0)
         u=dot(refract(worldLightVector,vec3(0.,-1.,0.),.750019),y.xyz);
       else
          K=.5/(max(0.,pow(worldLightVector.y,2.)*2.)+.4);
       float J=u*u,O=PhaseMie(.8,u,J);
       I+=TintUnderwaterDepth(j*colorSunlight*GetWaterFogColor()*.075*O*K*(1.-wetness));
     }
   }
   if(i.sky<.5&&isEyeInWater<1)
     LandAtmosphericScattering(I,r.xyz,n.xyz,y.xyz,worldSunVector.xyz,1.);
   I/=120.;
   I*=exp(-t*blindness);
   I=pow(I.xyz,vec3(.454545));
   gl_FragData[0]=vec4(I,X.w);
 };





/* DRAWBUFFERS:3 */

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

in float timeSunriseSunset;
in float timeNoon;
in float timeMidnight;
in float timeSkyDark;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSunglow;
in vec3 colorBouncedSunlight;
in vec3 colorScatteredSunlight;
in vec3 colorTorchlight;
in vec3 colorWaterMurk;
in vec3 colorWaterBlue;
in vec3 colorSkyTint;



in vec3 upVector;



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
   int x=v.x*v.y;
   return t(f(floor(pow(float(x),.333333))));
 }
 int f()
 {
   ivec2 v=ivec2(2048,2048);
   int x=v.x*v.y;
   return d(f(floor(pow(float(x),.333333))));
 }
 vec3 n(vec2 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=f.x*f.y,y=d();
   ivec2 n=ivec2(v.x*f.x,v.y*f.y);
   float z=float(n.y/y),i=float(int(n.x+mod(f.x*z,y))/y);
   i+=floor(f.x*z/y);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(f.x*z,y),y);
   m.y=mod(n.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 x(vec3 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float y=i.z;
   vec2 n;
   n.x=mod(i.x+y*x,f.x);
   float c=i.x+y*x;
   n.y=i.y+floor(c/f.x)*x;
   n+=.5;
   n/=f;
   return n;
 }
 vec3 s(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=f();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float z=float(n.y/y),r=float(int(n.x+mod(m.x*z,y))/y);
   r+=floor(m.x*z/y);
   vec3 c=vec3(0.,0.,r);
   c.x=mod(n.x+mod(m.x*z,y),y);
   c.y=mod(n.y,y);
   c.xyz=floor(c.xyz);
   c/=y;
   c.xyz=c.xzy;
   return c;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 f=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 n;
   n.x=mod(i.x+x*y,f.x);
   float c=i.x+x*y;
   n.y=i.y+floor(c/f.x)*y;
   n+=.5;
   n/=f;
   n.xy*=.5;
   return n;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 n(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 e(vec3 v)
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
   vec3 v=cameraPosition.xyz+.5,f=previousCameraPosition.xyz+.5,x=floor(v-.0001),y=floor(f-.0001);
   return x-y;
 }
 vec3 m(vec3 v)
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
 vec3 d(vec3 v,vec3 f,vec2 n,vec2 x,vec4 i,vec4 m,inout float y,out vec2 c)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(m.x==8||m.x==9||m.x==79||m.x<1.||!r||m.x==20.||m.x==171.||min(abs(f.x),abs(f.z))>.2)
     y=1.;
   if(m.x==50.||m.x==76.)
     {
       y=0.;
       if(f.y<.5)
         y=1.;
     }
   if(m.x==51)
     y=0.;
   if(m.x>255)
     y=0.;
   vec3 z,s;
   if(f.x>.5)
     z=vec3(0.,0.,-1.),s=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       z=vec3(0.,0.,1.),s=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         z=vec3(1.,0.,0.),s=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           z=vec3(1.,0.,0.),s=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             z=vec3(1.,0.,0.),s=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               z=vec3(-1.,0.,0.),s=vec3(0.,-1.,0.);
   c=clamp((n.xy-x.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(m.x==10.||m.x==11.)
     {
       if(abs(f.y)<.01&&r||f.y>.99)
         h=.1,e=.1,y=0.;
       else
          y=1.;
     }
   if(m.x==51)
     h=.5,e=.1;
   if(m.x==76)
     h=.2,e=.2;
   if(m.x-255.+39.>=103.&&m.x-255.+39.<=113.)
     e=.025,h=.025;
   z=normalize(i.xyz);
   s=normalize(cross(z,f.xyz)*sign(i.w));
   vec3 d=v.xyz+mix(z*h,-z*h,vec3(c.x));
   d.xyz+=mix(s*h,-s*h,vec3(c.y));
   d.xyz-=f.xyz*e;
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
 void d(in Ray v,in vec3 f[2],out float i,out float y)
 {
   float x,z,r,n;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),n);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,n=(f-v)*.5,i=y-z,r=vec3(0.);
   r+=vec3(sign(i.x),0.,0.)*step(abs(abs(i.x)-n.x),x);
   r+=vec3(0.,sign(i.y),0.)*step(abs(abs(i.y)-n.y),x);
   r+=vec3(0.,0.,sign(i.z))*step(abs(abs(i.z)-n.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),n=min(x,y),c=max(x,y);
   vec2 r=max(n.xx,n.yz);
   float z=max(r.x,r.y);
   r=min(c.xx,c.yz);
   float s=min(r.x,r.y);
   i.x=z;
   i.y=s;
   return s>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float y,inout vec3 x)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),i=m.inv_direction*(f+1e-05-m.origin),n=min(i,z),c=max(i,z);
   vec2 r=max(n.xx,n.yz);
   float s=max(r.x,r.y);
   r=min(c.xx,c.yz);
   float G=min(r.x,r.y);
   bool t=G>max(s,0.)&&max(s,0.)<y;
   if(t)
     x=d(v-1e-05,f+1e-05,m.origin+m.direction*s),y=s;
   return t;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float n=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*n),2).x;
   r*=saturate(dot(f,y));
   {
     vec4 c=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float s=abs(c.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,s),t=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     r=mix(r,r*h,1.-t);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 f,vec3 x,vec3 z,int n)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=v(y),c=m(i+x*.99);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(c.xy,c.z-.0006*s),3).x;
   r*=saturate(dot(f,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(c.xy-vec2(.5,0.),c.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(c.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-t));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float n=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*n),2).x;
   r*=saturate(dot(f,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float s=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*n),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-s));
   #endif
   return r*(1.-rainStrength);
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
 DADTHOtuFY i(vec4 v)
 {
   DADTHOtuFY f;
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),i=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   f.GFxtWSLmhV=v.x;
   f.TBAojABNgn=m.y;
   f.TGVjqUPLfE=i.y;
   f.OGZTEviGjn=n.y;
   f.lZygmXBJpl=pow(vec3(m.x,i.x,n.x),vec3(8.));
   return f;
 }
 DADTHOtuFY G(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return i(texture2DLod(colortex5,v,0));
 }
 float G(float v,float y)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+y,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool G(vec3 v,float y,Ray f,bool x,inout float i,inout vec3 z)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(x)
     return false;
   if(y>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),f,i,z);
   r=m;
   #else
   if(y<40.)
     return m=d(v,v+vec3(1.,1.,1.),f,i,z),m;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float s=.5;
       if(y==41.)
         s=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),f,i,z);
       r=r||m;
     }
   if(y==42.||y>=55.&&y<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),f,i,z),r=r||m;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         s=0.;
       m=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),f,i,z);
       r=r||m;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         s=0.;
       m=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),f,i,z);
       r=r||m;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float s=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         s=0.;
       m=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),f,i,z);
       r=r||m;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float s=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         s=0.;
       m=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),f,i,z);
       r=r||m;
     }
   if(y>=67.&&y<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,f,i,z),r=r||m;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float s=8.,c=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         s=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         c=16.;
       m=d(v+vec3(s,6.,7.)/16.,v+vec3(c,9.,9.)/16.,f,i,z);
       r=r||m;
       m=d(v+vec3(s,12.,7.)/16.,v+vec3(c,15.,9.)/16.,f,i,z);
       r=r||m;
     }
   if(y>=71.&&y<=82.)
     {
       float s=8.,n=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         n=16.;
       if(y>=75.&&y<=82.)
         s=0.;
       m=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,n)/16.,f,i,z);
       r=r||m;
       m=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,n)/16.,f,i,z);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 s=vec3(0),n=vec3(0);
       if(y==83.)
         s=vec3(0,0,0),n=vec3(16,16,3);
       if(y==84.)
         s=vec3(0,0,13),n=vec3(16,16,16);
       if(y==86.)
         s=vec3(0,0,0),n=vec3(3,16,16);
       if(y==85.)
         s=vec3(13,0,0),n=vec3(16,16,16);
       m=d(v+s/16.,v+n/16.,f,i,z);
       r=r||m;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float c=0.;
           if(y>=91.&&y<=94.)
             c=13.;
           s=vec3(0.,c,0.)/16.;
           n=vec3(16.,c+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float c=13.;
           if(y==97.||y==98.)
             c=0.;
           s=vec3(0.,0.,c)/16.;
           n=vec3(16.,16.,c+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float c=13.;
           if(y==99.||y==100.)
             c=0.;
           s=vec3(c,0.,0.)/16.;
           n=vec3(c+3.,16.,16.)/16.;
         }
       m=d(v+s,v+n,f,i,z);
       r=r||m;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float c=float(y)-float(103.)+1.;
           n.y=c*2./16.;
         }
       if(y==111.)
         n.y=.0625;
       if(y==112.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(y==113.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       m=d(v+s,v+n,f,i,z);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 float e(float v,float y)
 {
   return exp(-pow(v/(.9*y),2.));
 }
 float h(vec3 v,vec3 y)
 {
   return dot(abs(v-y),vec3(.3333));
 }
 vec3 R(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight))/64.;
   const vec2 f[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 i=texture2D(noisetex,y).xyz,z=vec3(sqrt(.2),sqrt(2.),1.61803);
   i=mod(i+vec3(z)*mod(frameCounter,64.f),vec3(1.));
   return i;
 }
 vec3 G(float v,float f,float x,vec3 y)
 {
   vec3 i;
   i.x=x*cos(v);
   i.y=x*sin(v);
   i.z=f;
   vec3 s=abs(y.y)<.999?vec3(0,0,1):vec3(1,0,0),r=normalize(cross(y,vec3(0.,1.,1.))),n=cross(r,y);
   return r*i.x+n*i.y+y*i.z;
 }
 vec3 G(vec2 v,float f,vec3 y)
 {
   float s=2*3.14159*v.x,z=sqrt((1-v.y)/(1+(f*f-1)*v.y)),i=sqrt(1-z*z);
   return G(s,z,i,y);
 }
 float c(float v)
 {
   return 2./(v*v+1e-07)-2.;
 }
 vec3 R(in vec2 v,in float y,in vec3 z)
 {
   float f=c(y),i=2*3.14159*v.x,x=pow(v.y,1.f/(f+1.f)),s=sqrt(1-x*x);
   return G(i,x,s,z);
 }
 float a(vec2 v)
 {
   return texture2DLod(colortex3,v,0).w;
 }
 float R(float v,float y)
 {
   return v/(y*20.01+1.);
 }
 vec2 a(vec2 v,float y)
 {
   vec2 s=v;
   mat2 x=mat2(cos(y),-sin(y),sin(y),cos(y));
   v=x*v;
   return v;
 }
 vec4 G(sampler2D v,float f,bool y,float i,float s,float z,float x)
 {
   GBufferData m=GetGBufferData();
   GBufferDataTransparent n=GetGBufferDataTransparent();
   bool r=n.depth<m.depth;
   if(r)
     m.normal=n.normal,m.smoothness=n.smoothness,m.metalness=0.,m.mcLightmap=n.mcLightmap,m.depth=n.depth;
   vec4 c=GetViewPosition(texcoord.xy,m.depth),e=gbufferModelViewInverse*vec4(c.xyz,1.),d=gbufferModelViewInverse*vec4(c.xyz,0.);
   vec3 t=normalize(c.xyz),o=normalize(d.xyz),l=normalize((gbufferModelViewInverse*vec4(m.normal,0.)).xyz);
   float p=GetDepthLinear(texcoord.xy),w=dot(-t,m.normal.xyz),T=1.-m.smoothness,b=T*T,Y=G(m.smoothness,m.metalness);
   vec4 W=texture2DLod(colortex6,texcoord.xy,0);
   float q=Luminance(W.xyz);
   if(Y<.001)
     return W;
   float g=f*.9;
   g*=min(b*20.,1.1);
   g*=mix(W.w,1.,1.);
   vec2 V=vec2(0.);
   if(y)
     {
       vec2 P=BlueNoiseTemporal(texcoord.xy).xy*.99+.005;
       V=P-.5;
     }
   float P=0.,E=1.1,M=R(i,m.totalTexGrad)/(b+.0001),S=R(s,m.totalTexGrad);
   vec4 D=vec4(0.),u=vec4(0.);
   float F=0.;
   vec4 I=vec4(vec3(z),1.);
   I.xyz=vec3(.5);
   I.xyz*=W.w*.95+.05;
   float O=m.smoothness;
   vec2 L=normalize(cross(m.normal,t).xy),B=a(L,1.5708);
   float A=1.-pow(1.-saturate(w),1.);
   L*=mix(.1675,.5,A);
   B*=mix(mix(.7,.7,b),.5,A);
   vec3 H=reflect(-t,m.normal);
   int j=0;
   for(int Z=-1;Z<=1;Z++)
     {
       for(int U=-1;U<=1;U++)
         {
           vec2 N=vec2(Z,U)+V;
           N=N.x*L+N.y*B;
           N*=g*1.5/vec2(viewWidth,viewHeight);
           vec2 K=texcoord.xy+N.xy;
           float C=length(N*vec2(viewWidth,viewHeight));
           if(C*.025>W.w+.1)
             {
               continue;
             }
           K=clamp(K,4./vec2(viewWidth,viewHeight),1.-4./vec2(viewWidth,viewHeight));
           vec4 X=texture2DLod(colortex6,K,0);
           vec3 J=GetNormals(K);
           float Q=GetDepthLinear(K),k=pow(saturate(dot(H,reflect(-t,J))),105./b),ab=exp(-(abs(Q-p)*E)),ac=exp(-(h(X.xyz,W.xyz)*P)),ad=exp(-abs(O-a(K))*S),ae=k*ab*ac*ad;
           D+=vec4(pow(length(X.xyz),I.x)*normalize(X.xyz+1e-10),X.w)*ae;
           F+=ae;
           u+=X;
           j++;
         }
     }
   D/=F+.0001;
   D.xyz=pow(length(D.xyz),1./I.x)*normalize(D.xyz+1e-06);
   vec4 N=D;
   if(F<.001)
     N=W;
   return N;
 }
 void main()
 {
   vec4 v=texture2DLod(colortex6,texcoord.xy,4);
   vec3 y=pow(texture2DLod(colortex3,texcoord.xy,2).xyz,vec3(2.2)),z=GetViewPosition(texcoord.xy,GetDepth(texcoord.xy)).xyz,x=GetNormals(texcoord.xy);
   float m=pow(1.-saturate(dot(-normalize(z),x)),5.);
   v.xyz*=m;
   float s=dot(max(vec3(0.),vec3(v.xyz-y.xyz*20.)),vec3(240.));
   vec4 f=texture2DLod(colortex6,texcoord.xy,0);
   f=G(colortex6,30.,false,180.,40.,.1,0.);
   f=max(f,vec4(0.));
   gl_FragData[0]=vec4(f);
 };




/* DRAWBUFFERS:6 */

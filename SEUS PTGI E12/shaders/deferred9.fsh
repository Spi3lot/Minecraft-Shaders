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







in vec4 texcoord;


#include "lib/Uniforms.inc"
#include "lib/Common.inc"
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
 vec3 x(vec2 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=m.x*m.y,y=d();
   ivec2 f=ivec2(v.x*m.x,v.y*m.y);
   float z=float(f.y/y),i=float(int(f.x+mod(m.x*z,y))/y);
   i+=floor(m.x*z/y);
   vec3 r=vec3(0.,0.,i);
   r.x=mod(f.x+mod(m.x*z,y),y);
   r.y=mod(f.y,y);
   r.xyz=floor(r.xyz);
   r/=y;
   r.xyz=r.xzy;
   return r;
 }
 vec2 n(vec3 v)
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
 vec3 r(vec2 v)
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
   vec3 f=v.xzy*y;
   f=floor(f+1e-05);
   float x=f.z;
   vec2 i;
   i.x=mod(f.x+x*y,m.x);
   float s=f.x+x*y;
   i.y=f.y+floor(s/m.x)*y;
   i+=.5;
   i/=m;
   i.xy*=.5;
   return i;
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
 vec3 s(vec3 v)
 {
   int x=d();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 p(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 n()
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
 vec3 d(vec3 v,vec3 f,vec2 m,vec2 x,vec4 i,vec4 s,inout float y,out vec2 r)
 {
   bool z=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   z=!z;
   if(s.x==8||s.x==9||s.x==79||s.x<1.||!z||s.x==20.||s.x==171.||min(abs(f.x),abs(f.z))>.2)
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
   vec3 n,a;
   if(f.x>.5)
     n=vec3(0.,0.,-1.),a=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       n=vec3(0.,0.,1.),a=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         n=vec3(1.,0.,0.),a=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           n=vec3(1.,0.,0.),a=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             n=vec3(1.,0.,0.),a=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               n=vec3(-1.,0.,0.),a=vec3(0.,-1.,0.);
   r=clamp((m.xy-x.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(s.x==10.||s.x==11.)
     {
       if(abs(f.y)<.01&&z||f.y>.99)
         h=.1,e=.1,y=0.;
       else
          y=1.;
     }
   if(s.x==51)
     h=.5,e=.1;
   if(s.x==76)
     h=.2,e=.2;
   if(s.x-255.+39.>=103.&&s.x-255.+39.<=113.)
     e=.025,h=.025;
   n=normalize(i.xyz);
   a=normalize(cross(n,f.xyz)*sign(i.w));
   vec3 d=v.xyz+mix(n*h,-n*h,vec3(r.x));
   d.xyz+=mix(a*h,-a*h,vec3(r.y));
   d.xyz-=f.xyz*e;
   return d;
 }struct qconKIZlZt{vec3 pnOlPKItYq;vec3 pnOlPKItYqOrigin;vec3 WsbjjPghQe;vec3 InIGjfhCoM;vec3 aeHOcnbAiW;vec3 zmecwWmFca;};
 qconKIZlZt e(Ray v)
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
 void h(inout qconKIZlZt v)
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
   vec3 z=(f+v)*.5,n=(f-v)*.5,s=y-z,i=vec3(0.);
   i+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-n.x),x);
   i+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-n.y),x);
   i+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-n.z),x);
   return normalize(i);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),s=min(x,y),n=max(x,y);
   vec2 r=max(s.xx,s.yz);
   float z=max(r.x,r.y);
   r=min(n.xx,n.yz);
   float e=min(r.x,r.y);
   i.x=z;
   i.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float y,inout vec3 x)
 {
   vec3 i=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(f+1e-05-m.origin),n=min(s,i),r=max(s,i);
   vec2 a=max(n.xx,n.yz);
   float z=max(a.x,a.y);
   a=min(r.xx,r.yz);
   float e=min(a.x,a.y);
   bool t=e>max(z,0.)&&max(z,0.)<y;
   if(t)
     x=d(v-1e-05,f+1e-05,m.origin+m.direction*z),y=z;
   return t;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=m(v);
   float n=.5;
   vec3 i=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*n),2).x;
   i*=saturate(dot(f,y));
   {
     vec4 r=texture2DLod(shadowcolor1,s.xy-vec2(0.,.5),4);
     float a=abs(r.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,a),t=shadow2DLod(shadowtex0,vec3(s.xy-vec2(0.,.5),s.z+1e-06),4).x;
     i=mix(i,i*h,1.-t);
   }
   i=TintUnderwaterDepth(i);
   return i*(1.-rainStrength);
 }
 vec3 f(vec3 f,vec3 s,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=v(f),n=m(i+y*.99);
   float t=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*t),3).x;
   r*=saturate(dot(s,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float a=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*t),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-a));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 h(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=m(v);
   float n=.5;
   vec3 i=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*n),2).x;
   i*=saturate(dot(f,y));
   i=TintUnderwaterDepth(i);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*n),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   i=mix(i,i*e,vec3(1.-r));
   #endif
   return i*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 w(DADTHOtuFY v)
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
   vec2 s=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   f.GFxtWSLmhV=v.x;
   f.TBAojABNgn=s.y;
   f.TGVjqUPLfE=m.y;
   f.OGZTEviGjn=n.y;
   f.lZygmXBJpl=pow(vec3(s.x,m.x,n.x),vec3(8.));
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
 bool G(vec3 v,float y,Ray f,bool x,inout float i,inout vec3 n)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(x)
     return false;
   if(y>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),f,i,n);
   m=r;
   #else
   if(y<40.)
     return r=d(v,v+vec3(1.,1.,1.),f,i,n),r;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float z=.5;
       if(y==41.)
         z=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,z,1.),f,i,n);
       m=m||r;
     }
   if(y==42.||y>=55.&&y<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),f,i,n),m=m||r;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float z=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         z=0.;
       r=d(v+vec3(0.,z,0.),v+vec3(.5,.5+z,.5),f,i,n);
       m=m||r;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float z=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         z=0.;
       r=d(v+vec3(.5,z,0.),v+vec3(1.,.5+z,.5),f,i,n);
       m=m||r;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float z=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         z=0.;
       r=d(v+vec3(.5,z,.5),v+vec3(1.,.5+z,1.),f,i,n);
       m=m||r;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float z=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         z=0.;
       r=d(v+vec3(0.,z,.5),v+vec3(.5,.5+z,1.),f,i,n);
       m=m||r;
     }
   if(y>=67.&&y<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,f,i,n),m=m||r;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float z=8.,s=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         z=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         s=16.;
       r=d(v+vec3(z,6.,7.)/16.,v+vec3(s,9.,9.)/16.,f,i,n);
       m=m||r;
       r=d(v+vec3(z,12.,7.)/16.,v+vec3(s,15.,9.)/16.,f,i,n);
       m=m||r;
     }
   if(y>=71.&&y<=82.)
     {
       float z=8.,a=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         a=16.;
       if(y>=75.&&y<=82.)
         z=0.;
       r=d(v+vec3(7.,6.,z)/16.,v+vec3(9.,9.,a)/16.,f,i,n);
       m=m||r;
       r=d(v+vec3(7.,12.,z)/16.,v+vec3(9.,15.,a)/16.,f,i,n);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 z=vec3(0),a=vec3(0);
       if(y==83.)
         z=vec3(0,0,0),a=vec3(16,16,3);
       if(y==84.)
         z=vec3(0,0,13),a=vec3(16,16,16);
       if(y==86.)
         z=vec3(0,0,0),a=vec3(3,16,16);
       if(y==85.)
         z=vec3(13,0,0),a=vec3(16,16,16);
       r=d(v+z/16.,v+a/16.,f,i,n);
       m=m||r;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 z=vec3(0.),a=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float s=0.;
           if(y>=91.&&y<=94.)
             s=13.;
           z=vec3(0.,s,0.)/16.;
           a=vec3(16.,s+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float s=13.;
           if(y==97.||y==98.)
             s=0.;
           z=vec3(0.,0.,s)/16.;
           a=vec3(16.,16.,s+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float s=13.;
           if(y==99.||y==100.)
             s=0.;
           z=vec3(s,0.,0.)/16.;
           a=vec3(s+3.,16.,16.)/16.;
         }
       r=d(v+z,v+a,f,i,n);
       m=m||r;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 z=vec3(0.),s=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float a=float(y)-float(103.)+1.;
           s.y=a*2./16.;
         }
       if(y==111.)
         s.y=.0625;
       if(y==112.)
         z=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(y==113.)
         z=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       r=d(v+z,v+s,f,i,n);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 void d(inout float v,inout float y,float f,float i,vec3 s,float x)
 {
   #if GI_FILTER_QUALITY==0
   v*=mix(2.4,2.6,i);
   #else
   v*=mix(2.4,3.4,i);
   #endif
   float z=dot(s,vec3(1.));
   y*=1.-pow(i,.4);
   y/=f*.1+2e-06;
   y*=2.4;
   float r=f/(z+1e-07)*.1+4e-08;
   r*=1.5;
   r=min(r,1.);
   r=mix(r,1.,pow(i,.25));
   if(x<.12)
     y=0.;
 }
 float G(vec3 v,vec3 y,float m)
 {
   float i=dot(abs(v-y),vec3(.3333));
   i*=m;
   i*=.18;
   return i;
 }
 vec4 G(sampler2D v,vec2 f,bool y,float m,float z,vec2 i,const bool x,out float r)
 {
   DADTHOtuFY s=G(f.xy);
   r=s.TGVjqUPLfE;
   vec4 n=texture2DLod(v,f.xy,0);
   vec3 a=n.xyz;
   float e=n.w;
   if(r<.95&&x)
     return n;
   vec3 h,t;
   GetBothNormals(f.xy,h,t);
   float c=GetDepth(f.xy),o=ExpToLinearDepth(c);
   vec3 l=GetViewPosition(f.xy,c).xyz;
   vec2 W=vec2(0.);
   if(y)
     W=BlueNoiseTemporal(f.xy).xy-.5;
   float p=m*1,w=z;
   d(p,w,n.w,r,a,o);
   float R=24.*mix(4.,1.,r),Y=mix(20.,10.,r)/o,b=0.;
   vec4 q=vec4(0.);
   float T=0.;
   int g=0;
   for(int D=-1;D<=1;D+=1)
     {
       {
         vec2 F=vec2(D+W.x)/vec2(viewWidth,viewHeight)*p*i,E=f.xy+F.xy;
         float I=length(F*vec2(viewWidth,viewHeight));
         E=clamp(E,4./vec2(viewWidth,viewHeight),1.-4./vec2(viewWidth,viewHeight));
         vec4 P=texture2DLod(v,E,0);
         vec3 B,V;
         GetBothNormals(E,B,V);
         float O=GetDepth(E),M=ExpToLinearDepth(O),S=pow(saturate(dot(h,B)),R),U=exp(-(abs(M-o)*Y)),u=0.;
         vec3 L=GetViewPosition(E,O).xyz,A=L.xyz-l.xyz;
         float H=length(A);
         vec3 j=A/(H+1e-06);
         float Z=dot(t,j);
         bool N=Z>.05&&Luminance(P.xyz)<Luminance(a.xyz);
         float K=1.;
         if(N&&H<.3)
           S=K;
         u=exp(-G(P.xyz,a,w));
         float X=U*u*S;
         q+=P*X;
         T+=X;
         g++;
       }
     }
   q/=T+.0001;
   if(T<.0001)
     q=n;
   return q;
 }
 void main()
 {
   float v;
   vec4 f=G(colortex6,texcoord.xy,true,8.,8.,vec2(0.,1.),false,v);
   float y=1.;
   if(texcoord.y<.25)
     {
       vec2 s=texcoord.xy*vec2(4.,4.),n=vec2(s.x,(s.y-floor(mod(FRAME_TIME*60.f,60.f)))/60.f);
       if(texcoord.x<.25)
         y=texture2DLod(colortex0,n.xy,0).x;
       else
          if(texcoord.x>.25&&texcoord.x<.5)
           y=texture2DLod(colortex0,n.xy,0).y;
         else
            if(texcoord.x>.5&&texcoord.x<.75)
             y=texture2DLod(colortex0,n.xy,0).z;
           else
              y=texture2DLod(colortex0,n.xy,0).w;
     }
   vec2 i=1.-abs(texcoord.xy*2.-1.);
   i=saturate(i*10.);
   float z=min(i.x,i.y);
   f.xyz*=mix(vec3(1.),BlueNoiseTemporal(texcoord.xy).xyz*2.,vec3(1.-pow(v,2.5))*.35*z);
   gl_FragData[0]=vec4(f.xyz,y);
 };




/* DRAWBUFFERS:6 */

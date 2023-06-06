#version 330 compatibility
#extension GL_ARB_shading_language_packing : enable
#extension GL_ARB_shader_bit_encoding : enable


#include "lib/Uniforms.inc"
#include "lib/Common.inc"
#include "lib/GBuffersCommon.inc"


in vec4 texcoord;
in vec4 color;
// in vec4 lmcoord;

// in vec3 normal;
in vec4 viewPos;
in vec3 voxelSpacePos;

in float materialIDs;
in float mcEntity;
in float isWater;
in float isStainedGlass;


in float invalidForVolume;
in float PnlUBUYgWr;
in float fragDepth;

in vec2 xnnPLOZALC;


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
   int x=f.x*f.y,z=d();
   ivec2 n=ivec2(v.x*f.x,v.y*f.y);
   float y=float(n.y/z),i=float(int(n.x+mod(f.x*y,z))/z);
   i+=floor(f.x*y/z);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(f.x*y,z),z);
   m.y=mod(n.y,z);
   m.xyz=floor(m.xyz);
   m/=z;
   m.xyz=m.xzy;
   return m;
 }
 vec2 s(vec3 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float y=i.z;
   vec2 n;
   n.x=mod(i.x+y*x,f.x);
   float m=i.x+y*x;
   n.y=i.y+floor(m/f.x)*x;
   n+=.5;
   n/=f;
   return n;
 }
 vec3 x(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,z=f();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float y=float(n.y/z),r=float(int(n.x+mod(m.x*y,z))/z);
   r+=floor(m.x*y/z);
   vec3 s=vec3(0.,0.,r);
   s.x=mod(n.x+mod(m.x*y,z),z);
   s.y=mod(n.y,z);
   s.xyz=floor(s.xyz);
   s/=z;
   s.xyz=s.xzy;
   return s;
 }
 vec2 d(vec3 v,int f)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*f;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 n;
   n.x=mod(i.x+x*f,m.x);
   float y=i.x+x*f;
   n.y=i.y+floor(y/m.x)*f;
   n+=.5;
   n/=m;
   n.xy*=.5;
   return n;
 }
 vec3 f(vec3 v,int f)
 {
   return v*=1./f,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 n(vec3 v,int f)
 {
   return v*=1./f,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int x=f();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 r(vec3 v)
 {
   int x=d();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 p(vec3 v)
 {
   int f=d();
   v=v-vec3(.5);
   v*=f;
   return v;
 }
 vec3 n()
 {
   vec3 v=cameraPosition.xyz+.5,x=previousCameraPosition.xyz+.5,i=floor(v-.0001),z=floor(x-.0001);
   return i-z;
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
 vec3 d(vec3 v,vec3 f,vec2 n,vec2 x,vec4 i,vec4 m,inout float z,out vec2 y)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(m.x==8||m.x==9||m.x==79||m.x<1.||!r||m.x==20.||m.x==171.||min(abs(f.x),abs(f.z))>.2)
     z=1.;
   if(m.x==50.||m.x==76.)
     {
       z=0.;
       if(f.y<.5)
         z=1.;
     }
   if(m.x==51)
     z=0.;
   if(m.x>255)
     z=0.;
   vec3 s,a;
   if(f.x>.5)
     s=vec3(0.,0.,-1.),a=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       s=vec3(0.,0.,1.),a=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         s=vec3(1.,0.,0.),a=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           s=vec3(1.,0.,0.),a=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             s=vec3(1.,0.,0.),a=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               s=vec3(-1.,0.,0.),a=vec3(0.,-1.,0.);
   y=clamp((n.xy-x.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(m.x==10.||m.x==11.)
     {
       if(abs(f.y)<.01&&r||f.y>.99)
         h=.1,e=.1,z=0.;
       else
          z=1.;
     }
   if(m.x==51)
     h=.5,e=.1;
   if(m.x==76)
     h=.2,e=.2;
   if(m.x-255.+39.>=103.&&m.x-255.+39.<=113.)
     e=.025,h=.025;
   s=normalize(i.xyz);
   a=normalize(cross(s,f.xyz)*sign(i.w));
   vec3 l=v.xyz+mix(s*h,-s*h,vec3(y.x));
   l.xyz+=mix(a*h,-a*h,vec3(y.y));
   l.xyz-=f.xyz*e;
   return l;
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
 void i(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float x)
 {
   float z,y,r,n;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   z=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   y=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,z),r);
   x=min(min(x,y),n);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 z)
 {
   const float x=1e-05;
   vec3 y=(f+v)*.5,i=(f-v)*.5,m=z-y,n=vec3(0.);
   n+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-i.x),x);
   n+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-i.y),x);
   n+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-i.z),x);
   return normalize(n);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 z=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),n=min(x,z),s=max(x,z);
   vec2 r=max(n.xx,n.yz);
   float y=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float a=min(r.x,r.y);
   i.x=y;
   i.y=a;
   return a>max(y,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float x,inout vec3 z)
 {
   vec3 y=m.inv_direction*(v-1e-05-m.origin),i=m.inv_direction*(f+1e-05-m.origin),n=min(i,y),s=max(i,y);
   vec2 r=max(n.xx,n.yz);
   float a=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float h=min(r.x,r.y);
   bool e=h>max(a,0.)&&max(a,0.)<x;
   if(e)
     z=d(v-1e-05,f+1e-05,m.origin+m.direction*a),x=a;
   return e;
 }
 vec3 e(vec3 v,vec3 f,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float n=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*n),2).x;
   r*=saturate(dot(f,z));
   {
     vec4 s=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float a=abs(s.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,a),e=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     r=mix(r,r*h,1.-e);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 f,vec3 x,vec3 z,vec3 y,int n)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=v(f),s=m(i+z*.99);
   float a=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*a),3).x;
   r*=saturate(dot(x,z));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float e=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*a),3).x;
   vec3 h=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   h*=h;
   r=mix(r,r*h,vec3(1.-e));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 f,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float n=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*n),2).x;
   r*=saturate(dot(f,z));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float a=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*n),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   r=mix(r,r*s,vec3(1.-a));
   #endif
   return r*(1.-rainStrength);
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
 DADTHOtuFY h(vec4 v)
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
 DADTHOtuFY D(vec2 v)
 {
   vec2 f=1./vec2(viewWidth,viewHeight),z=vec2(viewWidth,viewHeight);
   v=(floor(v*z)+.5)*f;
   return h(texture2DLod(colortex5,v,0));
 }
 float D(float v,float f)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+f,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool D(vec3 v,float f,Ray x,bool z,inout float i,inout vec3 y)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(z)
     return false;
   if(f>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),x,i,y);
   r=m;
   #else
   if(f<40.)
     return m=d(v,v+vec3(1.,1.,1.),x,i,y),m;
   if(f==40.||f==41.||f>=43.&&f<=54.)
     {
       float s=.5;
       if(f==41.)
         s=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),x,i,y);
       r=r||m;
     }
   if(f==42.||f>=55.&&f<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),x,i,y),r=r||m;
   if(f==43.||f==46.||f==47.||f==52.||f==53.||f==54.||f==55.||f==58.||f==59.||f==64.||f==65.||f==66.)
     {
       float s=.5;
       if(f==55.||f==58.||f==59.||f==64.||f==65.||f==66.)
         s=0.;
       m=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),x,i,y);
       r=r||m;
     }
   if(f==43.||f==45.||f==48.||f==51.||f==53.||f==54.||f==55.||f==57.||f==60.||f==63.||f==65.||f==66.)
     {
       float s=.5;
       if(f==55.||f==57.||f==60.||f==63.||f==65.||f==66.)
         s=0.;
       m=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),x,i,y);
       r=r||m;
     }
   if(f==44.||f==45.||f==49.||f==51.||f==52.||f==54.||f==56.||f==57.||f==61.||f==63.||f==64.||f==66.)
     {
       float s=.5;
       if(f==56.||f==57.||f==61.||f==63.||f==64.||f==66.)
         s=0.;
       m=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),x,i,y);
       r=r||m;
     }
   if(f==44.||f==46.||f==50.||f==51.||f==52.||f==53.||f==56.||f==58.||f==62.||f==63.||f==64.||f==65.)
     {
       float s=.5;
       if(f==56.||f==58.||f==62.||f==63.||f==64.||f==65.)
         s=0.;
       m=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),x,i,y);
       r=r||m;
     }
   if(f>=67.&&f<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,x,i,y),r=r||m;
   if(f==68.||f==69.||f==70.||f==72.||f==73.||f==74.||f==76.||f==77.||f==78.||f==80.||f==81.||f==82.)
     {
       float s=8.,n=8.;
       if(f==68.||f==70.||f==72.||f==74.||f==76.||f==78.||f==80.||f==82.)
         s=0.;
       if(f==69.||f==70.||f==73.||f==74.||f==77.||f==78.||f==81.||f==82.)
         n=16.;
       m=d(v+vec3(s,6.,7.)/16.,v+vec3(n,9.,9.)/16.,x,i,y);
       r=r||m;
       m=d(v+vec3(s,12.,7.)/16.,v+vec3(n,15.,9.)/16.,x,i,y);
       r=r||m;
     }
   if(f>=71.&&f<=82.)
     {
       float s=8.,n=8.;
       if(f>=71.&&f<=74.||f>=79.&&f<=82.)
         n=16.;
       if(f>=75.&&f<=82.)
         s=0.;
       m=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,n)/16.,x,i,y);
       r=r||m;
       m=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,n)/16.,x,i,y);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(f>=83.&&f<=86.)
     {
       vec3 s=vec3(0),n=vec3(0);
       if(f==83.)
         s=vec3(0,0,0),n=vec3(16,16,3);
       if(f==84.)
         s=vec3(0,0,13),n=vec3(16,16,16);
       if(f==86.)
         s=vec3(0,0,0),n=vec3(3,16,16);
       if(f==85.)
         s=vec3(13,0,0),n=vec3(16,16,16);
       m=d(v+s/16.,v+n/16.,x,i,y);
       r=r||m;
     }
   if(f>=87.&&f<=102.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(f>=87.&&f<=94.)
         {
           float a=0.;
           if(f>=91.&&f<=94.)
             a=13.;
           s=vec3(0.,a,0.)/16.;
           n=vec3(16.,a+3.,16.)/16.;
         }
       if(f>=95.&&f<=98.)
         {
           float a=13.;
           if(f==97.||f==98.)
             a=0.;
           s=vec3(0.,0.,a)/16.;
           n=vec3(16.,16.,a+3.)/16.;
         }
       if(f>=99.&&f<=102.)
         {
           float a=13.;
           if(f==99.||f==100.)
             a=0.;
           s=vec3(a,0.,0.)/16.;
           n=vec3(a+3.,16.,16.)/16.;
         }
       m=d(v+s,v+n,x,i,y);
       r=r||m;
     }
   if(f>=103.&&f<=113.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(f>=103.&&f<=110.)
         {
           float a=float(f)-float(103.)+1.;
           n.y=a*2./16.;
         }
       if(f==111.)
         n.y=.0625;
       if(f==112.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(f==113.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       m=d(v+s,v+n,x,i,y);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 vec4 e(in sampler2D v,in vec2 f)
 {
   vec2 m=vec2(64.f,64.f);
   f*=m;
   f+=.5f;
   vec2 x=floor(f),i=fract(f);
   i.x=i.x*i.x*(3.f-2.f*i.x);
   i.y=i.y*i.y*(3.f-2.f*i.y);
   f=x+i;
   f-=.5f;
   f/=m;
   return texture2D(v,f);
 }
 float D(in float v,in float f,in float x)
 {
   if(v>f)
     return v;
   float s=2.f*x-f,z=2.f*f-3.f*x,i=v/f;
   return(s*i+z)*i*i+x;
 }
 float G(vec3 v)
 {
   float f=.5f;
   vec2 i=v.xz/20.f;
   i.xy-=v.y/20.f;
   i.x=-i.x;
   i.x+=FRAME_TIME/40.f*f;
   i.y-=FRAME_TIME/40.f*f;
   float x=1.f,r=x,n=0.f,m=e(noisetex,i*vec2(2.f,1.2f)+vec2(0.f,i.x*2.1f)).x;
   i/=2.1f;
   i.y-=FRAME_TIME/20.f*f;
   i.x-=FRAME_TIME/30.f*f;
   n+=m*.5;
   x=2.1f;
   r+=x;
   m=e(noisetex,i*vec2(2.f,1.4f)+vec2(0.f,-i.x*2.1f)).x;
   i/=1.5f;
   i.x+=FRAME_TIME/20.f*f;
   m*=x;
   n+=m;
   x=17.25f;
   r+=x;
   m=e(noisetex,i*vec2(1.f,.75f)+vec2(0.f,i.x*1.1f)).x;
   i/=1.5f;
   i.x-=FRAME_TIME/55.f*f;
   m*=x;
   n+=m;
   x=15.25f;
   r+=x;
   m=e(noisetex,i*vec2(1.f,.75f)+vec2(0.f,-i.x*1.7f)).x;
   i/=1.9f;
   i.x+=FRAME_TIME/155.f*f;
   m*=x;
   n+=m;
   x=29.25f;
   r+=x;
   m=abs(e(noisetex,i*vec2(1.f,.8f)+vec2(0.f,-i.x*1.7f)).x*2.f-1.f);
   i/=2.f;
   i.x+=FRAME_TIME/155.f*f;
   m=1.f-D(m,.2f,.1f);
   m*=x;
   n+=m;
   x=15.25f;
   r+=x;
   m=abs(e(noisetex,i*vec2(1.f,.8f)+vec2(0.f,i.x*1.7f)).x*2.f-1.f);
   m=1.f-D(m,.2f,.1f);
   m*=x;
   n+=m;
   n/=r;
   return n;
 }
 void main()
 {
   vec4 f=texture2D(texture,texcoord.xy,0);
   vec3 v=f.xyz*color.xyz;
   float x=1.;
   if(PnlUBUYgWr<.5)
     {
       x=min(f.w*7.,1.);
       vec3 i=(shadowModelViewInverse*vec4(viewPos.xyz,1.)).xyz;
       i+=cameraPosition.xyz;
       gl_FragData[0]=vec4(v.xyz,x);
       gl_FragData[1]=vec4(i.y/256.,1.-isWater,0.,x);
     }
   else
     {
       if(invalidForVolume>.0001)
         {
           discard;
         }
       vec3 s=voxelSpacePos+cameraPosition.xyz;
       v*=v;
       if(abs(mcEntity-50.)<.1)
         v.xyz=GetColorTorchlight()*.1*GI_LIGHT_TORCH_INTENSITY;
       if(abs(mcEntity-76.)<.1)
         v.xyz=vec3(1.,.02,.01)*.05*GI_LIGHT_TORCH_INTENSITY;
       if(abs(mcEntity-51.)<.1)
         v.xyz=vec3(2.,.35,.025);
       float i=clamp((abs(color.x-color.y)+abs(color.x-color.z)+abs(color.y-color.z))*500.,0.,1.);
       v.xyz=normalize(v.xyz+1e-05)*min(length(v.xyz),.95);
       gl_FragData[0]=vec4(v.xyz,(materialIDs+.1)/255.*x);
       gl_FragData[1]=vec4(xnnPLOZALC.xy,i,dot(f.xyz,vec3(.33333)));
     }
 };




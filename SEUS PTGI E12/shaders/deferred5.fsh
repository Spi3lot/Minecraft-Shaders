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
 vec2 n(vec3 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float y=i.z;
   vec2 n;
   n.x=mod(i.x+y*x,f.x);
   float s=i.x+y*x;
   n.y=i.y+floor(s/f.x)*x;
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
   vec2 f=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 n;
   n.x=mod(i.x+x*y,f.x);
   float s=i.x+x*y;
   n.y=i.y+floor(s/f.x)*y;
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
 vec3 p(vec3 v)
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
 vec3 n()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,x=floor(v-.0001),y=floor(i-.0001);
   return x-y;
 }
 vec3 m(vec3 v)
 {
   vec4 i=vec4(v,1.);
   i=shadowModelView*i;
   i=shadowProjection*i;
   i/=i.w;
   float x=sqrt(i.x*i.x+i.y*i.y),y=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   i.xy*=.95f/y;
   i.z=mix(i.z,.5,.8);
   i=i*.5f+.5f;
   i.xy*=.5;
   i.xy+=.5;
   return i.xyz;
 }
 vec3 d(vec3 v,vec3 i,vec2 n,vec2 f,vec4 m,vec4 s,inout float x,out vec2 y)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(s.x==8||s.x==9||s.x==79||s.x<1.||!r||s.x==20.||s.x==171.||min(abs(i.x),abs(i.z))>.2)
     x=1.;
   if(s.x==50.||s.x==76.)
     {
       x=0.;
       if(i.y<.5)
         x=1.;
     }
   if(s.x==51)
     x=0.;
   if(s.x>255)
     x=0.;
   vec3 z,a;
   if(i.x>.5)
     z=vec3(0.,0.,-1.),a=vec3(0.,-1.,0.);
   else
      if(i.x<-.5)
       z=vec3(0.,0.,1.),a=vec3(0.,-1.,0.);
     else
        if(i.y>.5)
         z=vec3(1.,0.,0.),a=vec3(0.,0.,1.);
       else
          if(i.y<-.5)
           z=vec3(1.,0.,0.),a=vec3(0.,0.,-1.);
         else
            if(i.z>.5)
             z=vec3(1.,0.,0.),a=vec3(0.,-1.,0.);
           else
              if(i.z<-.5)
               z=vec3(-1.,0.,0.),a=vec3(0.,-1.,0.);
   y=clamp((n.xy-f.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(s.x==10.||s.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         h=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(s.x==51)
     h=.5,e=.1;
   if(s.x==76)
     h=.2,e=.2;
   if(s.x-255.+39.>=103.&&s.x-255.+39.<=113.)
     e=.025,h=.025;
   z=normalize(m.xyz);
   a=normalize(cross(z,i.xyz)*sign(m.w));
   vec3 l=v.xyz+mix(z*h,-z*h,vec3(y.x));
   l.xyz+=mix(a*h,-a*h,vec3(y.y));
   l.xyz-=i.xyz*e;
   return l;
 }struct qconKIZlZt{vec3 pnOlPKItYq;vec3 pnOlPKItYqOrigin;vec3 WsbjjPghQe;vec3 InIGjfhCoM;vec3 aeHOcnbAiW;vec3 zmecwWmFca;};
 qconKIZlZt e(Ray v)
 {
   qconKIZlZt i;
   i.pnOlPKItYq=floor(v.origin);
   i.pnOlPKItYqOrigin=i.pnOlPKItYq;
   i.WsbjjPghQe=abs(vec3(length(v.direction))/(v.direction+1e-07));
   i.InIGjfhCoM=sign(v.direction);
   i.aeHOcnbAiW=(sign(v.direction)*(i.pnOlPKItYq-v.origin)+sign(v.direction)*.5+.5)*i.WsbjjPghQe;
   i.zmecwWmFca=vec3(0.);
   return i;
 }
 void h(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void d(in Ray v,in vec3 i[2],out float f,out float x)
 {
   float y,z,r,n;
   f=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=max(max(f,y),r);
   x=min(min(x,z),n);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(i+v)*.5,n=(i-v)*.5,s=y-z,f=vec3(0.);
   f+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-n.x),x);
   f+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-n.y),x);
   f+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-n.z),x);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 f)
 {
   vec3 x=m.inv_direction*(v-m.origin),y=m.inv_direction*(i-m.origin),s=min(y,x),n=max(y,x);
   vec2 r=max(s.xx,s.yz);
   float z=max(r.x,r.y);
   r=min(n.xx,n.yz);
   float e=min(r.x,r.y);
   f.x=z;
   f.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),n=min(s,z),f=max(s,z);
   vec2 r=max(n.xx,n.yz);
   float h=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float e=min(r.x,r.y);
   bool a=e>max(h,0.)&&max(h,0.)<x;
   if(a)
     y=d(v-1e-05,i+1e-05,m.origin+m.direction*h),x=h;
   return a;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=m(v);
   float n=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*n),2).x;
   f*=saturate(dot(i,y));
   {
     vec4 r=texture2DLod(shadowcolor1,s.xy-vec2(0.,.5),4);
     float a=abs(r.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,a),e=shadow2DLod(shadowtex0,vec3(s.xy-vec2(0.,.5),s.z+1e-06),4).x;
     f=mix(f,f*h,1.-e);
   }
   f=TintUnderwaterDepth(f);
   return f*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 i,vec3 x,vec3 f,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 s=v(y),n=m(s+x*.99);
   float h=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*h),3).x;
   r*=saturate(dot(i,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float a=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*h),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-a));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 h(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=m(v);
   float f=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*f),2).x;
   r*=saturate(dot(i,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*f),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-n));
   #endif
   return r*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 w(DADTHOtuFY v)
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
   vec2 s=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   i.GFxtWSLmhV=v.x;
   i.TBAojABNgn=s.y;
   i.TGVjqUPLfE=m.y;
   i.OGZTEviGjn=n.y;
   i.lZygmXBJpl=pow(vec3(s.x,m.x,n.x),vec3(8.));
   return i;
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
 bool G(vec3 v,float x,Ray i,bool y,inout float f,inout vec3 n)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(x>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),i,f,n);
   r=m;
   #else
   if(x<40.)
     return m=d(v,v+vec3(1.,1.,1.),i,f,n),m;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float z=.5;
       if(x==41.)
         z=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,z,1.),i,f,n);
       r=r||m;
     }
   if(x==42.||x>=55.&&x<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,n),r=r||m;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float z=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         z=0.;
       m=d(v+vec3(0.,z,0.),v+vec3(.5,.5+z,.5),i,f,n);
       r=r||m;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float z=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         z=0.;
       m=d(v+vec3(.5,z,0.),v+vec3(1.,.5+z,.5),i,f,n);
       r=r||m;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float z=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         z=0.;
       m=d(v+vec3(.5,z,.5),v+vec3(1.,.5+z,1.),i,f,n);
       r=r||m;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float z=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         z=0.;
       m=d(v+vec3(0.,z,.5),v+vec3(.5,.5+z,1.),i,f,n);
       r=r||m;
     }
   if(x>=67.&&x<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,n),r=r||m;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float z=8.,s=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         z=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         s=16.;
       m=d(v+vec3(z,6.,7.)/16.,v+vec3(s,9.,9.)/16.,i,f,n);
       r=r||m;
       m=d(v+vec3(z,12.,7.)/16.,v+vec3(s,15.,9.)/16.,i,f,n);
       r=r||m;
     }
   if(x>=71.&&x<=82.)
     {
       float z=8.,s=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         s=16.;
       if(x>=75.&&x<=82.)
         z=0.;
       m=d(v+vec3(7.,6.,z)/16.,v+vec3(9.,9.,s)/16.,i,f,n);
       r=r||m;
       m=d(v+vec3(7.,12.,z)/16.,v+vec3(9.,15.,s)/16.,i,f,n);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 z=vec3(0),s=vec3(0);
       if(x==83.)
         z=vec3(0,0,0),s=vec3(16,16,3);
       if(x==84.)
         z=vec3(0,0,13),s=vec3(16,16,16);
       if(x==86.)
         z=vec3(0,0,0),s=vec3(3,16,16);
       if(x==85.)
         z=vec3(13,0,0),s=vec3(16,16,16);
       m=d(v+z/16.,v+s/16.,i,f,n);
       r=r||m;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 z=vec3(0.),s=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float h=0.;
           if(x>=91.&&x<=94.)
             h=13.;
           z=vec3(0.,h,0.)/16.;
           s=vec3(16.,h+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float h=13.;
           if(x==97.||x==98.)
             h=0.;
           z=vec3(0.,0.,h)/16.;
           s=vec3(16.,16.,h+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float h=13.;
           if(x==99.||x==100.)
             h=0.;
           z=vec3(h,0.,0.)/16.;
           s=vec3(h+3.,16.,16.)/16.;
         }
       m=d(v+z,v+s,i,f,n);
       r=r||m;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 z=vec3(0.),s=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float e=float(x)-float(103.)+1.;
           s.y=e*2./16.;
         }
       if(x==111.)
         s.y=.0625;
       if(x==112.)
         z=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(x==113.)
         z=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       m=d(v+z,v+s,i,f,n);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 void d(inout float v,inout float x,float i,float y,vec3 f,float n)
 {
   #if GI_FILTER_QUALITY==0
   v*=mix(2.4,2.6,y);
   #else
   v*=mix(2.4,3.4,y);
   #endif
   float s=dot(f,vec3(1.));
   x*=1.-pow(y,.4);
   x/=i*.1+2e-06;
   x*=2.4;
   float r=i/(s+1e-07)*.1+4e-08;
   r*=1.5;
   r=min(r,1.);
   r=mix(r,1.,pow(y,.25));
   if(n<.12)
     x=0.;
 }
 float G(vec3 v,vec3 y,float m)
 {
   float x=dot(abs(v-y),vec3(.3333));
   x*=m;
   x*=.18;
   return x;
 }
 vec4 G(sampler2D v,vec2 i,bool x,float f,float m,vec2 z,const bool y,out float r)
 {
   DADTHOtuFY s=G(i.xy);
   r=s.TGVjqUPLfE;
   vec4 n=texture2DLod(v,i.xy,0);
   vec3 h=n.xyz;
   float e=n.w;
   if(r<.95&&y)
     return n;
   vec3 a,t;
   GetBothNormals(i.xy,a,t);
   float c=GetDepth(i.xy),l=ExpToLinearDepth(c);
   vec3 W=GetViewPosition(i.xy,c).xyz;
   vec2 p=vec2(0.);
   if(x)
     p=BlueNoiseTemporal(i.xy).xy-.5;
   float w=f*1,o=m;
   d(w,o,n.w,r,h,l);
   float R=24.*mix(4.,1.,r),Y=mix(20.,10.,r)/l,b=0.;
   vec4 q=vec4(0.);
   float T=0.;
   int g=0;
   for(int D=-1;D<=1;D+=1)
     {
       {
         vec2 I=vec2(D+p.x)/vec2(viewWidth,viewHeight)*w*z,E=i.xy+I.xy;
         float O=length(I*vec2(viewWidth,viewHeight));
         E=clamp(E,4./vec2(viewWidth,viewHeight),1.-4./vec2(viewWidth,viewHeight));
         vec4 P=texture2DLod(v,E,0);
         vec3 F,V;
         GetBothNormals(E,F,V);
         float M=GetDepth(E),u=ExpToLinearDepth(M),S=pow(saturate(dot(a,F)),R),U=exp(-(abs(u-l)*Y)),A=0.;
         vec3 B=GetViewPosition(E,M).xyz,L=B.xyz-W.xyz;
         float H=length(L);
         vec3 j=L/(H+1e-06);
         float Z=dot(t,j);
         bool N=Z>.05&&Luminance(P.xyz)<Luminance(h.xyz);
         float K=1.;
         if(N&&H<.3)
           S=K;
         A=exp(-G(P.xyz,h,o));
         float X=U*A*S;
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
 float e(float v,float y)
 {
   return exp(-pow(v/(.9*y),2.));
 }
 float h(vec3 v,vec3 y)
 {
   return dot(abs(v-y),vec3(.3333));
 }
 void main()
 {
   float v;
   vec4 x=G(colortex6,texcoord.xy,true,2.,2.,vec2(0.,1.),false,v);
   gl_FragData[0]=x;
 };




/* DRAWBUFFERS:6 */

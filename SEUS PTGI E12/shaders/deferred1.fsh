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
 vec2 r(vec3 v)
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
 vec3 p(vec3 v)
 {
   int x=d();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 s(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 n()
 {
   vec3 v=cameraPosition.xyz+.5,x=previousCameraPosition.xyz+.5,y=floor(v-.0001),i=floor(x-.0001);
   return y-i;
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
 vec3 d(vec3 v,vec3 f,vec2 n,vec2 m,vec4 i,vec4 x,inout float y,out vec2 s)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(x.x==8||x.x==9||x.x==79||x.x<1.||!r||x.x==20.||x.x==171.||min(abs(f.x),abs(f.z))>.2)
     y=1.;
   if(x.x==50.||x.x==76.)
     {
       y=0.;
       if(f.y<.5)
         y=1.;
     }
   if(x.x==51)
     y=0.;
   if(x.x>255)
     y=0.;
   vec3 z,a;
   if(f.x>.5)
     z=vec3(0.,0.,-1.),a=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       z=vec3(0.,0.,1.),a=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         z=vec3(1.,0.,0.),a=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           z=vec3(1.,0.,0.),a=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             z=vec3(1.,0.,0.),a=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               z=vec3(-1.,0.,0.),a=vec3(0.,-1.,0.);
   s=clamp((n.xy-m.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(x.x==10.||x.x==11.)
     {
       if(abs(f.y)<.01&&r||f.y>.99)
         h=.1,e=.1,y=0.;
       else
          y=1.;
     }
   if(x.x==51)
     h=.5,e=.1;
   if(x.x==76)
     h=.2,e=.2;
   if(x.x-255.+39.>=103.&&x.x-255.+39.<=113.)
     e=.025,h=.025;
   z=normalize(i.xyz);
   a=normalize(cross(z,f.xyz)*sign(i.w));
   vec3 d=v.xyz+mix(z*h,-z*h,vec3(s.x));
   d.xyz+=mix(a*h,-a*h,vec3(s.y));
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
 void i(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float y)
 {
   float x,z,r,e;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   e=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),e);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,i=(f-v)*.5,n=y-z,r=vec3(0.);
   r+=vec3(sign(n.x),0.,0.)*step(abs(abs(n.x)-i.x),x);
   r+=vec3(0.,sign(n.y),0.)*step(abs(abs(n.y)-i.y),x);
   r+=vec3(0.,0.,sign(n.z))*step(abs(abs(n.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),n=min(x,y),s=max(x,y);
   vec2 r=max(n.xx,n.yz);
   float z=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float e=min(r.x,r.y);
   i.x=z;
   i.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),i=m.inv_direction*(f+1e-05-m.origin),n=min(i,z),s=max(i,z);
   vec2 r=max(n.xx,n.yz);
   float h=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float e=min(r.x,r.y);
   bool a=e>max(h,0.)&&max(h,0.)<x;
   if(a)
     y=d(v-1e-05,f+1e-05,m.origin+m.direction*h),x=h;
   return a;
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
     vec4 s=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float a=abs(s.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,a),e=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     r=mix(r,r*h,1.-e);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 f,vec3 x,vec3 y,vec3 z,int n)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=v(f),s=m(i+y*.99);
   float r=.5;
   vec3 a=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*r),3).x;
   a*=saturate(dot(x,y));
   a=TintUnderwaterDepth(a);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float e=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*r),3).x;
   vec3 h=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   h*=h;
   a=mix(a,a*h,vec3(1.-e));
   #endif
   return a*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 f,vec3 y,vec3 x,int z)
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
   float a=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*n),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   r=mix(r,r*s,vec3(1.-a));
   #endif
   return r*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 c(DADTHOtuFY v)
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
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),i=UnpackTwo16BitFrom32Bit(v.z),x=UnpackTwo16BitFrom32Bit(v.w);
   f.GFxtWSLmhV=v.x;
   f.TBAojABNgn=m.y;
   f.TGVjqUPLfE=i.y;
   f.OGZTEviGjn=x.y;
   f.lZygmXBJpl=pow(vec3(m.x,i.x,x.x),vec3(8.));
   return f;
 }
 DADTHOtuFY G(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return w(texture2DLod(colortex5,v,0));
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
 bool G(vec3 v,float x,Ray y,bool f,inout float i,inout vec3 z)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(f)
     return false;
   if(x>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),y,i,z);
   m=r;
   #else
   if(x<40.)
     return r=d(v,v+vec3(1.,1.,1.),y,i,z),r;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float a=.5;
       if(x==41.)
         a=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,a,1.),y,i,z);
       m=m||r;
     }
   if(x==42.||x>=55.&&x<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),y,i,z),m=m||r;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float a=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         a=0.;
       r=d(v+vec3(0.,a,0.),v+vec3(.5,.5+a,.5),y,i,z);
       m=m||r;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float a=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         a=0.;
       r=d(v+vec3(.5,a,0.),v+vec3(1.,.5+a,.5),y,i,z);
       m=m||r;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float a=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         a=0.;
       r=d(v+vec3(.5,a,.5),v+vec3(1.,.5+a,1.),y,i,z);
       m=m||r;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float a=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         a=0.;
       r=d(v+vec3(0.,a,.5),v+vec3(.5,.5+a,1.),y,i,z);
       m=m||r;
     }
   if(x>=67.&&x<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,y,i,z),m=m||r;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float a=8.,s=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         a=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         s=16.;
       r=d(v+vec3(a,6.,7.)/16.,v+vec3(s,9.,9.)/16.,y,i,z);
       m=m||r;
       r=d(v+vec3(a,12.,7.)/16.,v+vec3(s,15.,9.)/16.,y,i,z);
       m=m||r;
     }
   if(x>=71.&&x<=82.)
     {
       float a=8.,n=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         n=16.;
       if(x>=75.&&x<=82.)
         a=0.;
       r=d(v+vec3(7.,6.,a)/16.,v+vec3(9.,9.,n)/16.,y,i,z);
       m=m||r;
       r=d(v+vec3(7.,12.,a)/16.,v+vec3(9.,15.,n)/16.,y,i,z);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 a=vec3(0),s=vec3(0);
       if(x==83.)
         a=vec3(0,0,0),s=vec3(16,16,3);
       if(x==84.)
         a=vec3(0,0,13),s=vec3(16,16,16);
       if(x==86.)
         a=vec3(0,0,0),s=vec3(3,16,16);
       if(x==85.)
         a=vec3(13,0,0),s=vec3(16,16,16);
       r=d(v+a/16.,v+s/16.,y,i,z);
       m=m||r;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 a=vec3(0.),s=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float n=0.;
           if(x>=91.&&x<=94.)
             n=13.;
           a=vec3(0.,n,0.)/16.;
           s=vec3(16.,n+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float n=13.;
           if(x==97.||x==98.)
             n=0.;
           a=vec3(0.,0.,n)/16.;
           s=vec3(16.,16.,n+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float n=13.;
           if(x==99.||x==100.)
             n=0.;
           a=vec3(n,0.,0.)/16.;
           s=vec3(n+3.,16.,16.)/16.;
         }
       r=d(v+a,v+s,y,i,z);
       m=m||r;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 a=vec3(0.),s=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float n=float(x)-float(103.)+1.;
           s.y=n*2./16.;
         }
       if(x==111.)
         s.y=.0625;
       if(x==112.)
         a=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(x==113.)
         a=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       r=d(v+a,v+s,y,i,z);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 float c(float v,float y)
 {
   return exp(-pow(v/(.9*y),2.));
 }
 void main()
 {
   DADTHOtuFY v=G(texcoord.xy);
   float x=v.TGVjqUPLfE;
   vec4 f=texture2DLod(colortex6,texcoord.xy,0);
   vec3 m=f.xyz;
   float a=Luminance(m.xyz);
   vec3 r=GetNormals(texcoord.xy);
   float y=GetDepthLinear(texcoord.xy);
   vec2 z=vec2(0.);
   float i=4.,s=sin(frameTimeCounter)>0.?1.:0.;
   vec4 n=vec4(0.),e=vec4(0.);
   float h=0.;
   int t=0;
   for(int d=-1;d<=1;d++)
     {
       for(int R=-1;R<=1;R++)
         {
           vec2 l=(vec2(d,R)+z)/vec2(viewWidth,viewHeight)*i,o=texcoord.xy+l.xy;
           o=clamp(o,4./vec2(viewWidth,viewHeight),1.-4./vec2(viewWidth,viewHeight));
           vec4 p=texture2DLod(colortex6,o,0);
           n+=p;
           e+=p*p;
           t++;
         }
     }
   n/=t+1e-06;
   e/=t+1e-06;
   vec3 d=n.xyz;
   float l=dot(n.xyz,vec3(1.));
   vec4 p=sqrt(max(vec4(0.),e-n*n));
   float R=dot(p.xyz,vec3(6.));
   if(h<.0001)
     d=m;
   float o=x;
   for(int q=-1;q<=1;q++)
     {
       for(int w=-1;w<=1;w++)
         {
           vec2 W=vec2(q,w)/vec2(viewWidth,viewHeight),Y=texcoord.xy+W.xy;
           float E=G(Y.xy).TGVjqUPLfE;
           o=min(o,E);
         }
     }
   v.TGVjqUPLfE=o;
   gl_FragData[0]=c(v);
   gl_FragData[1]=vec4(f.xyz,R);
 };




/* DRAWBUFFERS:56 */

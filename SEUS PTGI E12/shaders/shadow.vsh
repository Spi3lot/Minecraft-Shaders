#version 330 compatibility


#include "lib/Uniforms.inc"
#include "lib/Common.inc"



attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;

out vec4 vTexcoord;
out vec4 vColor;
// out vec4 lmcoord;

// out vec3 normal;
out vec4 vViewPos;
out float vMaterialIDs;

out float vMCEntity;
// out float isWater;
// out float isStainedGlass;

out float MtqeGbdCLv;		
out float EPOFPmvdMH;			
out float fdUKYBKbny;			
out vec2 KWQDGvXhoA;			

out vec4 RvuBMHyIay;		
out vec4 tWOewJyFfe;		
// out vec3 voxelSpacePos;		    



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
   ivec2 x=ivec2(viewWidth,viewHeight);
   int s=x.x*x.y,y=d();
   ivec2 n=ivec2(v.x*x.x,v.y*x.y);
   float z=float(n.y/y),i=float(int(n.x+mod(x.x*z,y))/y);
   i+=floor(x.x*z/y);
   vec3 f=vec3(0.,0.,i);
   f.x=mod(n.x+mod(x.x*z,y),y);
   f.y=mod(n.y,y);
   f.xyz=floor(f.xyz);
   f/=y;
   f.xyz=f.xzy;
   return f;
 }
 vec2 n(vec3 v)
 {
   ivec2 x=ivec2(viewWidth,viewHeight);
   int y=d();
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float s=i.z;
   vec2 f;
   f.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   f.y=i.y+floor(m/x.x)*y;
   f+=.5;
   f/=x;
   return f;
 }
 vec3 r(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 x=ivec2(2048,2048);
   int s=x.x*x.y,y=f();
   ivec2 n=ivec2(i.x*x.x,i.y*x.y);
   float z=float(n.y/y),r=float(int(n.x+mod(x.x*z,y))/y);
   r+=floor(x.x*z/y);
   vec3 m=vec3(0.,0.,r);
   m.x=mod(n.x+mod(x.x*z,y),y);
   m.y=mod(n.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 x=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float s=i.z;
   vec2 f;
   f.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   f.y=i.y+floor(m/x.x)*y;
   f+=.5;
   f/=x;
   f.xy*=.5;
   return f;
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
   int x=f();
   v=v-vec3(.5);
   v*=x;
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
   int x=d();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 n()
 {
   vec3 v=cameraPosition.xyz+.5,x=previousCameraPosition.xyz+.5,y=floor(v-.0001),s=floor(x-.0001);
   return y-s;
 }
 vec3 m(vec3 v)
 {
   vec4 x=vec4(v,1.);
   x=shadowModelView*x;
   x=shadowProjection*x;
   x/=x.w;
   float s=sqrt(x.x*x.x+x.y*x.y),y=1.f-SHADOW_MAP_BIAS+s*SHADOW_MAP_BIAS;
   x.xy*=.95f/y;
   x.z=mix(x.z,.5,.8);
   x=x*.5f+.5f;
   x.xy*=.5;
   x.xy+=.5;
   return x.xyz;
 }
 vec3 d(vec3 v,vec3 m,vec2 x,vec2 y,vec4 n,vec4 f,inout float i,out vec2 s)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(f.x==8||f.x==9||f.x==79||f.x<1.||!r||f.x==20.||f.x==171.||min(abs(m.x),abs(m.z))>.2)
     i=1.;
   if(f.x==50.||f.x==76.)
     {
       i=0.;
       if(m.y<.5)
         i=1.;
     }
   if(f.x==51)
     i=0.;
   if(f.x>255)
     i=0.;
   vec3 z,a;
   if(m.x>.5)
     z=vec3(0.,0.,-1.),a=vec3(0.,-1.,0.);
   else
      if(m.x<-.5)
       z=vec3(0.,0.,1.),a=vec3(0.,-1.,0.);
     else
        if(m.y>.5)
         z=vec3(1.,0.,0.),a=vec3(0.,0.,1.);
       else
          if(m.y<-.5)
           z=vec3(1.,0.,0.),a=vec3(0.,0.,-1.);
         else
            if(m.z>.5)
             z=vec3(1.,0.,0.),a=vec3(0.,-1.,0.);
           else
              if(m.z<-.5)
               z=vec3(-1.,0.,0.),a=vec3(0.,-1.,0.);
   s=clamp((x.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float G=.15,e=.15;
   if(f.x==10.||f.x==11.)
     {
       if(abs(m.y)<.01&&r||m.y>.99)
         G=.1,e=.1,i=0.;
       else
          i=1.;
     }
   if(f.x==51)
     G=.5,e=.1;
   if(f.x==76)
     G=.2,e=.2;
   if(f.x-255.+39.>=103.&&f.x-255.+39.<=113.)
     e=.025,G=.025;
   z=normalize(n.xyz);
   a=normalize(cross(z,m.xyz)*sign(n.w));
   vec3 l=v.xyz+mix(z*G,-z*G,vec3(s.x));
   l.xyz+=mix(a*G,-a*G,vec3(s.y));
   l.xyz-=m.xyz*e;
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
 void d(in Ray v,in vec3 m[2],out float x,out float i)
 {
   float y,f,z,r;
   x=(m[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   i=(m[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(m[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   f=(m[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(m[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   r=(m[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,y),z);
   i=min(min(i,f),r);
 }
 vec3 d(const vec3 v,const vec3 x,vec3 y)
 {
   const float i=1e-05;
   vec3 z=(x+v)*.5,f=(x-v)*.5,m=y-z,s=vec3(0.);
   s+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-f.x),i);
   s+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-f.y),i);
   s+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-f.z),i);
   return normalize(s);
 }
 bool e(const vec3 v,const vec3 m,Ray f,out vec2 i)
 {
   vec3 x=f.inv_direction*(v-f.origin),y=f.inv_direction*(m-f.origin),n=min(y,x),s=max(y,x);
   vec2 r=max(n.xx,n.yz);
   float z=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float e=min(r.x,r.y);
   i.x=z;
   i.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 m,Ray f,inout float x,inout vec3 y)
 {
   vec3 i=f.inv_direction*(v-1e-05-f.origin),s=f.inv_direction*(m+1e-05-f.origin),n=min(s,i),a=max(s,i);
   vec2 r=max(n.xx,n.yz);
   float z=max(r.x,r.y);
   r=min(a.xx,a.yz);
   float G=min(r.x,r.y);
   bool e=G>max(z,0.)&&max(z,0.)<x;
   if(e)
     y=d(v-1e-05,m+1e-05,f.origin+f.direction*z),x=z;
   return e;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 x,int i)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 n=m(v);
   float z=.5;
   vec3 s=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*z),2).x;
   s*=saturate(dot(f,y));
   {
     vec4 r=texture2DLod(shadowcolor1,n.xy-vec2(0.,.5),4);
     float a=abs(r.x*256.-(v.y+cameraPosition.y)),e=GetCausticsComposite(v,f,a),G=shadow2DLod(shadowtex0,vec3(n.xy-vec2(0.,.5),n.z+1e-06),4).x;
     s=mix(s,s*e,1.-G);
   }
   s=TintUnderwaterDepth(s);
   return s*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 f,vec3 x,vec3 z,int i)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 s=v(y),n=m(s+x*.99);
   float G=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*G),3).x;
   r*=saturate(dot(f,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float e=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*G),3).x;
   vec3 a=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   a*=a;
   r=mix(r,r*a,vec3(1.-e));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 f,vec3 y,vec3 x,int i)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 n=m(v);
   float z=.5;
   vec3 s=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*z),2).x;
   s*=saturate(dot(f,y));
   s=TintUnderwaterDepth(s);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*z),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   s=mix(s,s*e,vec3(1.-r));
   #endif
   return s*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 G(DADTHOtuFY v)
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
   vec2 x=UnpackTwo16BitFrom32Bit(v.y),n=UnpackTwo16BitFrom32Bit(v.z),y=UnpackTwo16BitFrom32Bit(v.w);
   f.GFxtWSLmhV=v.x;
   f.TBAojABNgn=x.y;
   f.TGVjqUPLfE=n.y;
   f.OGZTEviGjn=y.y;
   f.lZygmXBJpl=pow(vec3(x.x,n.x,y.x),vec3(8.));
   return f;
 }
 DADTHOtuFY h(vec2 v)
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
 bool G(vec3 v,float x,Ray y,bool f,inout float i,inout vec3 n)
 {
   bool s=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(f)
     return false;
   if(x>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),y,i,n);
   s=m;
   #else
   if(x<40.)
     return m=d(v,v+vec3(1.,1.,1.),y,i,n),m;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float z=.5;
       if(x==41.)
         z=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,z,1.),y,i,n);
       s=s||m;
     }
   if(x==42.||x>=55.&&x<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),y,i,n),s=s||m;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float z=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         z=0.;
       m=d(v+vec3(0.,z,0.),v+vec3(.5,.5+z,.5),y,i,n);
       s=s||m;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float z=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         z=0.;
       m=d(v+vec3(.5,z,0.),v+vec3(1.,.5+z,.5),y,i,n);
       s=s||m;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float z=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         z=0.;
       m=d(v+vec3(.5,z,.5),v+vec3(1.,.5+z,1.),y,i,n);
       s=s||m;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float z=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         z=0.;
       m=d(v+vec3(0.,z,.5),v+vec3(.5,.5+z,1.),y,i,n);
       s=s||m;
     }
   if(x>=67.&&x<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,y,i,n),s=s||m;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float z=8.,r=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         z=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         r=16.;
       m=d(v+vec3(z,6.,7.)/16.,v+vec3(r,9.,9.)/16.,y,i,n);
       s=s||m;
       m=d(v+vec3(z,12.,7.)/16.,v+vec3(r,15.,9.)/16.,y,i,n);
       s=s||m;
     }
   if(x>=71.&&x<=82.)
     {
       float z=8.,r=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         r=16.;
       if(x>=75.&&x<=82.)
         z=0.;
       m=d(v+vec3(7.,6.,z)/16.,v+vec3(9.,9.,r)/16.,y,i,n);
       s=s||m;
       m=d(v+vec3(7.,12.,z)/16.,v+vec3(9.,15.,r)/16.,y,i,n);
       s=s||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 z=vec3(0),r=vec3(0);
       if(x==83.)
         z=vec3(0,0,0),r=vec3(16,16,3);
       if(x==84.)
         z=vec3(0,0,13),r=vec3(16,16,16);
       if(x==86.)
         z=vec3(0,0,0),r=vec3(3,16,16);
       if(x==85.)
         z=vec3(13,0,0),r=vec3(16,16,16);
       m=d(v+z/16.,v+r/16.,y,i,n);
       s=s||m;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 z=vec3(0.),r=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float e=0.;
           if(x>=91.&&x<=94.)
             e=13.;
           z=vec3(0.,e,0.)/16.;
           r=vec3(16.,e+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float e=13.;
           if(x==97.||x==98.)
             e=0.;
           z=vec3(0.,0.,e)/16.;
           r=vec3(16.,16.,e+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float e=13.;
           if(x==99.||x==100.)
             e=0.;
           z=vec3(e,0.,0.)/16.;
           r=vec3(e+3.,16.,16.)/16.;
         }
       m=d(v+z,v+r,y,i,n);
       s=s||m;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 z=vec3(0.),r=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float e=float(x)-float(103.)+1.;
           r.y=e*2./16.;
         }
       if(x==111.)
         r.y=.0625;
       if(x==112.)
         z=vec3(1.,0.,1.)/16.,r=vec3(15.,1.,15.)/16.;
       if(x==113.)
         z=vec3(1.,0.,1.)/16.,r=vec3(15.,.5,15.)/16.;
       m=d(v+z,v+r,y,i,n);
       s=s||m;
     }
   #endif
   #endif
   return s;
 }
 vec4 G(vec3 x,vec2 v,out float i,inout float z)
 {
   vec3 y=x;
   int s=f();
   x=clamp(x,vec3(1./s),vec3(1.-1./s));
   if(distance(x,y)>.005/s)
     z=1.;
   float m=dot(abs(x-y),vec3(1.));
   #ifdef MC_GL_VENDOR_ATI
   x-=1./float(s)*vec3(0.,0.,1.);
   #endif
   vec2 r=d(x,s);
   r+=v.xy*(1./vec2(4096));
   r=r*2.-1.;
   i=m;
   return vec4(r,i,1.);
 }
 void main()
 {
   gl_Position=ftransform();
   vTexcoord=gl_MultiTexCoord0;
   vMCEntity=mc_Entity.x;
   vViewPos=gl_ModelViewMatrix*gl_Vertex;
   vec4 v=gl_Position;
   v=shadowProjectionInverse*v;
   v=shadowModelViewInverse*v;
   v.xyz+=cameraPosition.xyz;
   vec3 x=v.xyz;
   vMaterialIDs=30.;
   float z=0.,r=0.f,s=0.f;
   if(mc_Entity.x==8||mc_Entity.x==9)
     z=1.f;
   if(mc_Entity.x==95||mc_Entity.x==160||mc_Entity.x==90||mc_Entity.x==165||mc_Entity.x==79)
     s=1.f;
   if(mc_Entity.x==79)
     r=1.f;
   if(mc_Entity.x==18.||mc_Entity.x==161.f)
     vMaterialIDs=36.;
   if(mc_Entity.x==79.f||mc_Entity.x==174.f)
     vMaterialIDs=37.;
   if(mc_Entity.x==50)
     vMaterialIDs=241.;
   if(mc_Entity.x==76)
     vMaterialIDs=241.;
   if(mc_Entity.x==10||mc_Entity.x==11)
     vMaterialIDs=241.;
   if(mc_Entity.x==89||mc_Entity.x==124||mc_Entity.x==10||mc_Entity.x==11||mc_Entity.x==169||mc_Entity.x==91)
     vMaterialIDs=31.;
   if(mc_Entity.x==51)
     vMaterialIDs=241.;
   #ifdef GLOWING_LAPIS_LAZULI_BLOCK
   if(mc_Entity.x==22)
     vMaterialIDs=31.;
   #endif
   #ifdef GLOWING_REDSTONE_BLOCK
   if(mc_Entity.x==152)
     vMaterialIDs=31.;
   #endif
   #ifdef GLOWING_EMERALD_BLOCK
   if(mc_Entity.x==133)
     vMaterialIDs=31.;
   #endif
   if(mc_Entity.x==95||mc_Entity.x==160)
     vMaterialIDs=240.;
   if(mc_Entity.x==188)
     vMaterialIDs=32.;
   if(mc_Entity.x==189)
     vMaterialIDs=33.;
   if(mc_Entity.x==190)
     vMaterialIDs=34.;
   if(mc_Entity.x==191)
     vMaterialIDs=35.;
   vec3 y=gl_Normal,i=normalize(gl_NormalMatrix*y);
   if(abs(vMaterialIDs-2.)<.1)
     y=vec3(0.,1.,0.);
   KWQDGvXhoA=mc_midTexCoord.xy;
   vColor=gl_Color;
   if(vMaterialIDs!=2.)
     {
       if(y.x>.85)
         vColor.xyz*=1./.6;
       if(y.x<-.85)
         vColor.xyz*=1./.6;
       if(y.z>.85)
         vColor.xyz*=1.25;
       if(y.z<-.85)
         vColor.xyz*=1.25;
       if(y.y<-.85)
         vColor.xyz*=2.;
     }
   MtqeGbdCLv=0.;
   {
     vec2 m;
     vec3 e=d(v.xyz,gl_Normal.xyz,vTexcoord.xy,mc_midTexCoord.xy,at_tangent,mc_Entity,MtqeGbdCLv,m);
     if(mc_Entity.x>255)
       vMaterialIDs=mc_Entity.x-255.+39.;
     e=floor(e);
     e-=cameraPosition.xyz;
     int a=f();
     e=n(e,a);
     RvuBMHyIay=G(e,m,fdUKYBKbny,MtqeGbdCLv);
     if(mc_Entity.x==51||mc_Entity.x==50||mc_Entity.x==76)
       fdUKYBKbny+=.9;
   }
   {
     v.xyz-=cameraPosition.xyz;
     v=shadowModelView*v;
     v=shadowProjection*v;
     gl_Position=v;
     float m=sqrt(gl_Position.x*gl_Position.x+gl_Position.y*gl_Position.y),e=1.f-SHADOW_MAP_BIAS+m*SHADOW_MAP_BIAS;
     gl_Position.xy*=.95f/e;
     gl_Position.xy*=.5;
     gl_Position.xy+=.5;
     if(z>.5)
       gl_Position.y-=1.;
     if(s>.5)
       gl_Position.x-=1.;
     gl_Position.z=mix(gl_Position.z,.5,.8);
     tWOewJyFfe=gl_Position;
     gl_FrontColor=gl_Color;
   }
 };




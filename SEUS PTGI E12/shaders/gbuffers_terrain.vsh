#version 330 compatibility


#define OLD_LIGHTING_FIX		//In newest versions of the shaders mod/optifine, old lighting isn't removed properly. If OldLighting is On and this is enabled, you'll get proper results in any shaders mod/minecraft version.

#define GLOWING_REDSTONE_BLOCK // If enabled, redstone blocks are treated as light sources for GI
#define GLOWING_LAPIS_LAZULI_BLOCK // If enabled, lapis lazuli blocks are treated as light sources for GI


#define GENERAL_GRASS_FIX

#include "lib/Uniforms.inc"
#include "lib/Common.inc"


attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;



out vec4 color;
out vec4 texcoord;
out vec4 lmcoord;
out vec3 worldPosition;
out vec3 viewPos;

out vec3 worldNormal;

out vec2 blockLight;

out float materialIDs;


#include "lib/Materials.inc"

 int f(float v)
 {
   return int(floor(v));
 }
 int t(int v)
 {
   return v-f(mod(float(v),2.))-0;
 }
 int s(int v)
 {
   return v-f(mod(float(v),2.))-1;
 }
 int f()
 {
   ivec2 v=ivec2(viewWidth,viewHeight);
   int x=v.x*v.y;
   return t(f(floor(pow(float(x),.333333))));
 }
 int s()
 {
   ivec2 v=ivec2(2048,2048);
   int x=v.x*v.y;
   return s(f(floor(pow(float(x),.333333))));
 }
 vec3 d(vec2 v)
 {
   ivec2 x=ivec2(viewWidth,viewHeight);
   int s=x.x*x.y,y=f();
   ivec2 n=ivec2(v.x*x.x,v.y*x.y);
   float z=float(n.y/y),i=float(int(n.x+mod(x.x*z,y))/y);
   i+=floor(x.x*z/y);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(x.x*z,y),y);
   m.y=mod(n.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 n(vec3 v)
 {
   ivec2 x=ivec2(viewWidth,viewHeight);
   int y=f();
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float s=i.z;
   vec2 r;
   r.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   r.y=i.y+floor(m/x.x)*y;
   r+=.5;
   r/=x;
   return r;
 }
 vec3 x(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 x=ivec2(2048,2048);
   int y=x.x*x.y,z=s();
   ivec2 n=ivec2(i.x*x.x,i.y*x.y);
   float f=float(n.y/z),r=float(int(n.x+mod(x.x*f,z))/z);
   r+=floor(x.x*f/z);
   vec3 m=vec3(0.,0.,r);
   m.x=mod(n.x+mod(x.x*f,z),z);
   m.y=mod(n.y,z);
   m.xyz=floor(m.xyz);
   m/=z;
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
   vec2 r;
   r.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   r.y=i.y+floor(m/x.x)*y;
   r+=.5;
   r/=x;
   r.xy*=.5;
   return r;
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
   int x=s();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 r(vec3 v)
 {
   int x=f();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 p(vec3 v)
 {
   int x=f();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,x=previousCameraPosition.xyz+.5,y=floor(v-.0001),z=floor(x-.0001);
   return y-z;
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
 vec3 d(vec3 v,vec3 m,vec2 x,vec2 y,vec4 n,vec4 f,inout float i,out vec2 r)
 {
   bool s=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   s=!s;
   if(f.x==8||f.x==9||f.x==79||f.x<1.||!s||f.x==20.||f.x==171.||min(abs(m.x),abs(m.z))>.2)
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
   vec3 z,w;
   if(m.x>.5)
     z=vec3(0.,0.,-1.),w=vec3(0.,-1.,0.);
   else
      if(m.x<-.5)
       z=vec3(0.,0.,1.),w=vec3(0.,-1.,0.);
     else
        if(m.y>.5)
         z=vec3(1.,0.,0.),w=vec3(0.,0.,1.);
       else
          if(m.y<-.5)
           z=vec3(1.,0.,0.),w=vec3(0.,0.,-1.);
         else
            if(m.z>.5)
             z=vec3(1.,0.,0.),w=vec3(0.,-1.,0.);
           else
              if(m.z<-.5)
               z=vec3(-1.,0.,0.),w=vec3(0.,-1.,0.);
   r=clamp((x.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float G=.15,E=.15;
   if(f.x==10.||f.x==11.)
     {
       if(abs(m.y)<.01&&s||m.y>.99)
         G=.1,E=.1,i=0.;
       else
          i=1.;
     }
   if(f.x==51)
     G=.5,E=.1;
   if(f.x==76)
     G=.2,E=.2;
   if(f.x-255.+39.>=103.&&f.x-255.+39.<=113.)
     E=.025,G=.025;
   z=normalize(n.xyz);
   w=normalize(cross(z,m.xyz)*sign(n.w));
   vec3 l=v.xyz+mix(z*G,-z*G,vec3(r.x));
   l.xyz+=mix(w*G,-w*G,vec3(r.y));
   l.xyz-=m.xyz*E;
   return l;
 }struct qconKIZlZt{vec3 pnOlPKItYq;vec3 pnOlPKItYqOrigin;vec3 WsbjjPghQe;vec3 InIGjfhCoM;vec3 aeHOcnbAiW;vec3 zmecwWmFca;};
 qconKIZlZt e(Ray v)
 {
   qconKIZlZt m;
   m.pnOlPKItYq=floor(v.origin);
   m.pnOlPKItYqOrigin=m.pnOlPKItYq;
   m.WsbjjPghQe=abs(vec3(length(v.direction))/(v.direction+1e-07));
   m.InIGjfhCoM=sign(v.direction);
   m.aeHOcnbAiW=(sign(v.direction)*(m.pnOlPKItYq-v.origin)+sign(v.direction)*.5+.5)*m.WsbjjPghQe;
   m.zmecwWmFca=vec3(0.);
   return m;
 }
 void G(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void G(in Ray v,in vec3 m[2],out float x,out float i)
 {
   float y,z,r,f;
   x=(m[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   i=(m[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(m[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(m[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(m[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=(m[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,y),r);
   i=min(min(i,z),f);
 }
 vec3 G(const vec3 v,const vec3 x,vec3 y)
 {
   const float z=1e-05;
   vec3 i=(x+v)*.5,m=(x-v)*.5,n=y-i,f=vec3(0.);
   f+=vec3(sign(n.x),0.,0.)*step(abs(abs(n.x)-m.x),z);
   f+=vec3(0.,sign(n.y),0.)*step(abs(abs(n.y)-m.y),z);
   f+=vec3(0.,0.,sign(n.z))*step(abs(abs(n.z)-m.z),z);
   return normalize(f);
 }
 bool d(const vec3 v,const vec3 x,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),z=m.inv_direction*(x-m.origin),n=min(z,y),f=max(z,y);
   vec2 r=max(n.xx,n.yz);
   float s=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float M=min(r.x,r.y);
   i.x=s;
   i.y=M;
   return M>max(s,0.);
 }
 bool G(const vec3 v,const vec3 x,Ray m,inout float y,inout vec3 z)
 {
   vec3 i=m.inv_direction*(v-1e-05-m.origin),f=m.inv_direction*(x+1e-05-m.origin),n=min(f,i),r=max(f,i);
   vec2 s=max(n.xx,n.yz);
   float w=max(s.x,s.y);
   s=min(r.xx,r.yz);
   float M=min(s.x,s.y);
   bool E=M>max(w,0.)&&max(w,0.)<y;
   if(E)
     z=G(v-1e-05,x+1e-05,m.origin+m.direction*w),y=w;
   return E;
 }
 vec3 d(vec3 v,vec3 x,vec3 y,vec3 f,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 n=m(v);
   float s=.5;
   vec3 i=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),2).x;
   i*=saturate(dot(x,y));
   {
     vec4 r=texture2DLod(shadowcolor1,n.xy-vec2(0.,.5),4);
     float w=abs(r.x*256.-(v.y+cameraPosition.y)),G=GetCausticsComposite(v,x,w),E=shadow2DLod(shadowtex0,vec3(n.xy-vec2(0.,.5),n.z+1e-06),4).x;
     i=mix(i,i*G,1.-E);
   }
   i=TintUnderwaterDepth(i);
   return i*(1.-rainStrength);
 }
 vec3 e(vec3 x,vec3 f,vec3 y,vec3 i,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 s=v(x),n=m(s+y*.99);
   float G=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*G),3).x;
   r*=saturate(dot(f,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float w=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*G),3).x;
   vec3 M=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   M*=M;
   r=mix(r,r*M,vec3(1.-w));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 x,vec3 y,vec3 f,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 n=m(v);
   float s=.5;
   vec3 i=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),2).x;
   i*=saturate(dot(x,y));
   i=TintUnderwaterDepth(i);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*s),3).x;
   vec3 M=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   M*=M;
   i=mix(i,i*M,vec3(1.-r));
   #endif
   return i*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 i(DADTHOtuFY v)
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
 DADTHOtuFY w(vec4 v)
 {
   DADTHOtuFY i;
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),x=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   i.GFxtWSLmhV=v.x;
   i.TBAojABNgn=m.y;
   i.TGVjqUPLfE=x.y;
   i.OGZTEviGjn=n.y;
   i.lZygmXBJpl=pow(vec3(m.x,x.x,n.x),vec3(8.));
   return i;
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
 bool G(vec3 v,float x,Ray i,bool y,inout float f,inout vec3 z)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(x>=67.)
     return false;
   r=G(v,v+vec3(1.,1.,1.),i,f,z);
   m=r;
   #else
   if(x<40.)
     return r=G(v,v+vec3(1.,1.,1.),i,f,z),r;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float s=.5;
       if(x==41.)
         s=.9375;
       r=G(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),i,f,z);
       m=m||r;
     }
   if(x==42.||x>=55.&&x<=66.)
     r=G(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,z),m=m||r;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         s=0.;
       r=G(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),i,f,z);
       m=m||r;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         s=0.;
       r=G(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),i,f,z);
       m=m||r;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float s=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         s=0.;
       r=G(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),i,f,z);
       m=m||r;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float s=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         s=0.;
       r=G(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),i,f,z);
       m=m||r;
     }
   if(x>=67.&&x<=82.)
     r=G(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,z),m=m||r;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float s=8.,n=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         s=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         n=16.;
       r=G(v+vec3(s,6.,7.)/16.,v+vec3(n,9.,9.)/16.,i,f,z);
       m=m||r;
       r=G(v+vec3(s,12.,7.)/16.,v+vec3(n,15.,9.)/16.,i,f,z);
       m=m||r;
     }
   if(x>=71.&&x<=82.)
     {
       float s=8.,n=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         n=16.;
       if(x>=75.&&x<=82.)
         s=0.;
       r=G(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,n)/16.,i,f,z);
       m=m||r;
       r=G(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,n)/16.,i,f,z);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 s=vec3(0),n=vec3(0);
       if(x==83.)
         s=vec3(0,0,0),n=vec3(16,16,3);
       if(x==84.)
         s=vec3(0,0,13),n=vec3(16,16,16);
       if(x==86.)
         s=vec3(0,0,0),n=vec3(3,16,16);
       if(x==85.)
         s=vec3(13,0,0),n=vec3(16,16,16);
       r=G(v+s/16.,v+n/16.,i,f,z);
       m=m||r;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float w=0.;
           if(x>=91.&&x<=94.)
             w=13.;
           s=vec3(0.,w,0.)/16.;
           n=vec3(16.,w+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float w=13.;
           if(x==97.||x==98.)
             w=0.;
           s=vec3(0.,0.,w)/16.;
           n=vec3(16.,16.,w+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float w=13.;
           if(x==99.||x==100.)
             w=0.;
           s=vec3(w,0.,0.)/16.;
           n=vec3(w+3.,16.,16.)/16.;
         }
       r=G(v+s,v+n,i,f,z);
       m=m||r;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float M=float(x)-float(103.)+1.;
           n.y=M*2./16.;
         }
       if(x==111.)
         n.y=.0625;
       if(x==112.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(x==113.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       r=G(v+s,v+n,i,f,z);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 void main()
 {
   color=gl_Color;
   texcoord=gl_MultiTexCoord0;
   lmcoord=gl_TextureMatrix[1]*gl_MultiTexCoord1;
   blockLight.x=clamp(lmcoord.x*33.05f/32.f-.0328125f,0.f,1.f);
   blockLight.y=clamp(lmcoord.y*33.75f/32.f-.0328125f,0.f,1.f);
   worldNormal=gl_Normal;
   vec4 x=gbufferModelViewInverse*gl_ModelViewMatrix*gl_Vertex;
   worldPosition=x.xyz+cameraPosition.xyz;
   viewPos=(gl_ModelViewMatrix*gl_Vertex).xyz;
   materialIDs=MAT_ID_OPAQUE;
   float v=0.f,s=abs(normalize(gl_Normal.xz).x),i=abs(gl_Normal.y);
   if(mc_Entity.x==31.||mc_Entity.x==38.f||mc_Entity.x==37.f||mc_Entity.x==1925.f||mc_Entity.x==1920.f||mc_Entity.x==1921.f||mc_Entity.x==2.&&gl_Normal.y<.5&&s>.01&&s<.99&&i<.9)
     materialIDs=MAT_ID_GRASS,v=1.f;
   #ifdef GENERAL_GRASS_FIX
   if(abs(worldNormal.x)>.01&&abs(worldNormal.x)<.99||abs(worldNormal.y)>.01&&abs(worldNormal.y)<.99||abs(worldNormal.z)>.01&&abs(worldNormal.z)<.99)
     materialIDs=MAT_ID_GRASS;
   #endif
   if(mc_Entity.x==175.f)
     materialIDs=MAT_ID_GRASS;
   if(mc_Entity.x==59.)
     materialIDs=MAT_ID_GRASS,v=1.f;
   if(mc_Entity.x==18.||mc_Entity.x==161.f)
     {
       if(color.x>.999&&color.y>.999&&color.z>.999)
         ;
       else
          materialIDs=MAT_ID_LEAVES;
       if(abs(color.x-color.y)>.001||abs(color.x-color.z)>.001||abs(color.y-color.z)>.001)
         materialIDs=MAT_ID_LEAVES;
     }
   if(mc_Entity.x==50)
     materialIDs=MAT_ID_TORCH;
   if(mc_Entity.x==10||mc_Entity.x==11)
     materialIDs=MAT_ID_LAVA;
   if(mc_Entity.x==89||mc_Entity.x==124||mc_Entity.x==169||mc_Entity.x==91)
     materialIDs=MAT_ID_GLOWSTONE;
   #ifdef GLOWING_REDSTONE_BLOCK
   if(mc_Entity.x==152)
     materialIDs=MAT_ID_GLOWSTONE;
   #endif
   #ifdef GLOWING_LAPIS_LAZULI_BLOCK
   if(mc_Entity.x==22)
     materialIDs=MAT_ID_GLOWSTONE;
   #endif
   #ifdef GLOWING_EMERALD_BLOCK
   if(mc_Entity.x==133)
     materialIDs=MAT_ID_GLOWSTONE;
   #endif
   if(mc_Entity.x==51)
     materialIDs=MAT_ID_FIRE;
   if(mc_Entity.x==188||mc_Entity.x==189||mc_Entity.x==190||mc_Entity.x==191)
     materialIDs=MAT_ID_LIT_FURNACE;
   float m=1.;
   if(color.x==1.&&color.y==1.&&color.z==1.)
     m=0.;
   #ifdef OLD_LIGHTING_FIX
   if(v<.1&&m>.5)
     {
       if(worldNormal.x>.85)
         color.xyz*=1./.6;
       if(worldNormal.x<-.85)
         color.xyz*=1./.6;
       if(worldNormal.z>.85)
         color.xyz*=1.25;
       if(worldNormal.z<-.85)
         color.xyz*=1.25;
       if(worldNormal.y<-.85)
         color.xyz*=2.;
     }
   #endif
   gl_Position=gl_ProjectionMatrix*gbufferModelView*x;
   gl_Position.xyz/=gl_Position.w;
   TemporalJitterProjPos(gl_Position);
   gl_Position.xyz*=gl_Position.w;
 };




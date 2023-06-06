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

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorTorchlight;
in vec3 colorSkyUp;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;

in vec3 worldLightVector;
in vec3 worldSunVector;

in float timeMidnight;

#include "lib/Uniforms.inc"
#include "lib/Common.inc"



/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








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






#include "lib/Materials.inc"
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
   vec3 s=vec3(0.,0.,r);
   s.x=mod(i.x+mod(f.x*z,y),y);
   s.y=mod(i.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
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
   float c=i.x+x*z;
   r.y=i.y+floor(c/f.x)*z;
   r+=.5;
   r/=f;
   return r;
 }
 vec3 e(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 s=ivec2(2048,2048);
   int x=s.x*s.y,y=f();
   ivec2 d=ivec2(i.x*s.x,i.y*s.y);
   float z=float(d.y/y),r=float(int(d.x+mod(s.x*z,y))/y);
   r+=floor(s.x*z/y);
   vec3 m=vec3(0.,0.,r);
   m.x=mod(d.x+mod(s.x*z,y),y);
   m.y=mod(d.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 f=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 r;
   r.x=mod(i.x+x*y,f.x);
   float s=i.x+x*y;
   r.y=i.y+floor(s/f.x)*y;
   r+=.5;
   r/=f;
   r.xy*=.5;
   return r;
 }
 vec3 e(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 f(vec3 v,int y)
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
 vec3 x(vec3 v)
 {
   int y=d();
   v*=1./y;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 n(vec3 v)
 {
   int f=d();
   v=v-vec3(.5);
   v*=f;
   return v;
 }
 vec3 e()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,y=floor(v-.0001),z=floor(i-.0001);
   return y-z;
 }
 vec3 p(vec3 v)
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
 vec3 d(vec3 v,vec3 f,vec2 i,vec2 y,vec4 s,vec4 d,inout float x,out vec2 r)
 {
   bool z=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   z=!z;
   if(d.x==8||d.x==9||d.x==79||d.x<1.||!z||d.x==20.||d.x==171.||min(abs(f.x),abs(f.z))>.2)
     x=1.;
   if(d.x==50.||d.x==76.)
     {
       x=0.;
       if(f.y<.5)
         x=1.;
     }
   if(d.x==51)
     x=0.;
   if(d.x>255)
     x=0.;
   vec3 c,t;
   if(f.x>.5)
     c=vec3(0.,0.,-1.),t=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       c=vec3(0.,0.,1.),t=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         c=vec3(1.,0.,0.),t=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           c=vec3(1.,0.,0.),t=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             c=vec3(1.,0.,0.),t=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               c=vec3(-1.,0.,0.),t=vec3(0.,-1.,0.);
   r=clamp((i.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float w=.15,e=.15;
   if(d.x==10.||d.x==11.)
     {
       if(abs(f.y)<.01&&z||f.y>.99)
         w=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(d.x==51)
     w=.5,e=.1;
   if(d.x==76)
     w=.2,e=.2;
   if(d.x-255.+39.>=103.&&d.x-255.+39.<=113.)
     e=.025,w=.025;
   c=normalize(s.xyz);
   t=normalize(cross(c,f.xyz)*sign(s.w));
   vec3 n=v.xyz+mix(c*w,-c*w,vec3(r.x));
   n.xyz+=mix(t*w,-t*w,vec3(r.y));
   n.xyz-=f.xyz*e;
   return n;
 }struct qconKIZlZt{vec3 pnOlPKItYq;vec3 pnOlPKItYqOrigin;vec3 WsbjjPghQe;vec3 InIGjfhCoM;vec3 aeHOcnbAiW;vec3 zmecwWmFca;};
 qconKIZlZt r(Ray v)
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
   float x,z,r,t;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   t=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),t);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,i=(f-v)*.5,d=y-z,r=vec3(0.);
   r+=vec3(sign(d.x),0.,0.)*step(abs(abs(d.x)-i.x),x);
   r+=vec3(0.,sign(d.y),0.)*step(abs(abs(d.y)-i.y),x);
   r+=vec3(0.,0.,sign(d.z))*step(abs(abs(d.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray s,out vec2 i)
 {
   vec3 y=s.inv_direction*(v-s.origin),x=s.inv_direction*(f-s.origin),d=min(x,y),c=max(x,y);
   vec2 r=max(d.xx,d.yz);
   float z=max(r.x,r.y);
   r=min(c.xx,c.yz);
   float m=min(r.x,r.y);
   i.x=z;
   i.y=m;
   return m>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray i,inout float y,inout vec3 x)
 {
   vec3 z=i.inv_direction*(v-1e-05-i.origin),c=i.inv_direction*(f+1e-05-i.origin),s=min(c,z),t=max(c,z);
   vec2 r=max(s.xx,s.yz);
   float m=max(r.x,r.y);
   r=min(t.xx,t.yz);
   float n=min(r.x,r.y);
   bool w=n>max(m,0.)&&max(m,0.)<y;
   if(w)
     x=d(v-1e-05,f+1e-05,i.origin+i.direction*m),y=m;
   return w;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=p(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,y));
   {
     vec4 d=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float t=abs(d.x*256.-(v.y+cameraPosition.y)),c=GetCausticsComposite(v,f,t),w=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     r=mix(r,r*c,1.-w);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=m(v),d=p(i+y*.99);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(d.xy,d.z-.0006*s),3).x;
   r*=saturate(dot(f,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(d.xy-vec2(.5,0.),d.z-.0006*s),3).x;
   vec3 n=texture2DLod(shadowcolor,vec2(d.xy-vec2(.5,0.)),3).xyz;
   n*=n;
   r=mix(r,r*n,vec3(1.-t));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=p(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*s),3).x;
   vec3 m=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   m*=m;
   r=mix(r,r*m,vec3(1.-t));
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
 DADTHOtuFY w(vec4 v)
 {
   DADTHOtuFY f;
   vec2 i=UnpackTwo16BitFrom32Bit(v.y),s=UnpackTwo16BitFrom32Bit(v.z),d=UnpackTwo16BitFrom32Bit(v.w);
   f.GFxtWSLmhV=v.x;
   f.TBAojABNgn=i.y;
   f.TGVjqUPLfE=s.y;
   f.OGZTEviGjn=d.y;
   f.lZygmXBJpl=pow(vec3(i.x,s.x,d.x),vec3(8.));
   return f;
 }
 DADTHOtuFY G(vec2 v)
 {
   vec2 z=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*z;
   return w(texture2DLod(colortex5,v,0));
 }
 float G(float v,float y)
 {
   float z=1.;
   #ifdef FULL_RT_REFLECTIONS
   z=clamp(pow(v,.125)+y,0.,1.);
   #else
   z=clamp(v*10.-7.,0.,1.);
   #endif
   return z;
 }
 bool G(vec3 v,float y,Ray f,bool z,inout float i,inout vec3 x)
 {
   bool r=false,s=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(z)
     return false;
   if(y>=67.)
     return false;
   s=d(v,v+vec3(1.,1.,1.),f,i,x);
   r=s;
   #else
   if(y<40.)
     return s=d(v,v+vec3(1.,1.,1.),f,i,x),s;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float c=.5;
       if(y==41.)
         c=.9375;
       s=d(v+vec3(0.,0.,0.),v+vec3(1.,c,1.),f,i,x);
       r=r||s;
     }
   if(y==42.||y>=55.&&y<=66.)
     s=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),f,i,x),r=r||s;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float c=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         c=0.;
       s=d(v+vec3(0.,c,0.),v+vec3(.5,.5+c,.5),f,i,x);
       r=r||s;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float c=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         c=0.;
       s=d(v+vec3(.5,c,0.),v+vec3(1.,.5+c,.5),f,i,x);
       r=r||s;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float c=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         c=0.;
       s=d(v+vec3(.5,c,.5),v+vec3(1.,.5+c,1.),f,i,x);
       r=r||s;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float c=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         c=0.;
       s=d(v+vec3(0.,c,.5),v+vec3(.5,.5+c,1.),f,i,x);
       r=r||s;
     }
   if(y>=67.&&y<=82.)
     s=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,f,i,x),r=r||s;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float c=8.,t=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         c=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         t=16.;
       s=d(v+vec3(c,6.,7.)/16.,v+vec3(t,9.,9.)/16.,f,i,x);
       r=r||s;
       s=d(v+vec3(c,12.,7.)/16.,v+vec3(t,15.,9.)/16.,f,i,x);
       r=r||s;
     }
   if(y>=71.&&y<=82.)
     {
       float c=8.,t=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         t=16.;
       if(y>=75.&&y<=82.)
         c=0.;
       s=d(v+vec3(7.,6.,c)/16.,v+vec3(9.,9.,t)/16.,f,i,x);
       r=r||s;
       s=d(v+vec3(7.,12.,c)/16.,v+vec3(9.,15.,t)/16.,f,i,x);
       r=r||s;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 c=vec3(0),t=vec3(0);
       if(y==83.)
         c=vec3(0,0,0),t=vec3(16,16,3);
       if(y==84.)
         c=vec3(0,0,13),t=vec3(16,16,16);
       if(y==86.)
         c=vec3(0,0,0),t=vec3(3,16,16);
       if(y==85.)
         c=vec3(13,0,0),t=vec3(16,16,16);
       s=d(v+c/16.,v+t/16.,f,i,x);
       r=r||s;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 c=vec3(0.),t=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float w=0.;
           if(y>=91.&&y<=94.)
             w=13.;
           c=vec3(0.,w,0.)/16.;
           t=vec3(16.,w+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float w=13.;
           if(y==97.||y==98.)
             w=0.;
           c=vec3(0.,0.,w)/16.;
           t=vec3(16.,16.,w+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float w=13.;
           if(y==99.||y==100.)
             w=0.;
           c=vec3(w,0.,0.)/16.;
           t=vec3(w+3.,16.,16.)/16.;
         }
       s=d(v+c,v+t,f,i,x);
       r=r||s;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 c=vec3(0.),t=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float m=float(y)-float(103.)+1.;
           t.y=m*2./16.;
         }
       if(y==111.)
         t.y=.0625;
       if(y==112.)
         c=vec3(1.,0.,1.)/16.,t=vec3(15.,1.,15.)/16.;
       if(y==113.)
         c=vec3(1.,0.,1.)/16.,t=vec3(15.,.5,15.)/16.;
       s=d(v+c,v+t,f,i,x);
       r=r||s;
     }
   #endif
   #endif
   return r;
 }
 vec2 g(inout float v)
 {
   return fract(sin(vec2(v+=.1,v+=.1))*vec2(43758.5,22578.1));
 }
 vec3 c(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight))/64.;
   const vec2 f[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   y+=f[int(mod(float(frameCounter),16.))]*.5;
   y=(floor(y*64.)+.5)/64.;
   vec3 z=texture2D(noisetex,y).xyz;
   return z;
 }
 vec3 G(vec3 v,inout float y,int z)
 {
   vec2 f=c(texcoord.xy+vec2(y+=.1,y+=.1)).xy;
   f=fract(f+g(y)*.1);
   float x=6.28319*f.x,i=sqrt(f.y);
   vec3 t=normalize(cross(v,vec3(0.,1.,1.))),r=cross(v,t),s=t*cos(x)*i+r*sin(x)*i+v.xyz*sqrt(1.-f.y);
   return s;
 }
 vec3 c(vec3 v,vec3 y)
 {
   vec2 f=s(x(m(v)+y+1.));
   vec3 z=G(f).lZygmXBJpl;
   return z;
 }
 vec3 G()
 {
   vec2 y=s(v(texcoord.xy)+e()/d());
   vec3 z=G(y).lZygmXBJpl;
   return z;
 }
 vec3 G(float v,float f,float y,vec3 i)
 {
   vec3 r;
   r.x=y*cos(v);
   r.y=y*sin(v);
   r.z=f;
   vec3 x=abs(i.y)<.999?vec3(0,0,1):vec3(1,0,0),c=normalize(cross(i,vec3(0.,1.,1.))),t=cross(c,i);
   return c*r.x+t*r.y+i*r.z;
 }
 vec3 c(vec2 v,float f,vec3 y)
 {
   float c=2*3.14159*v.x,x=sqrt((1-v.y)/(1+(f*f-1)*v.y)),i=sqrt(1-x*x);
   return G(c,x,i,y);
 }
 float l(float v)
 {
   return 2./(v*v+1e-07)-2.;
 }
 vec3 e(in vec2 v,in float y,in vec3 x)
 {
   float f=l(y),i=2*3.14159*v.x,z=pow(v.y,1.f/(f+1.f)),c=sqrt(1-z*z);
   return G(i,z,c,x);
 }
 float g(float v,float y)
 {
   return 1./(v*(1.-y)+y);
 }
 void h(inout vec3 v,in vec3 f)
 {
   vec3 y=normalize(f.xyz),i=v;
   float x=dot(i,y);
   i=normalize(v-y*saturate(x)*.5);
   v=i;
 }
 vec4 R(in vec2 v)
 {
   float y=GetDepth(v);
   vec4 f=gbufferProjectionInverse*vec4(v.x*2.f-1.f,v.y*2.f-1.f,2.f*y-1.f,1.f);
   f/=f.w;
   return f;
 }
 vec4 R(in vec2 v,in float y)
 {
   vec4 f=gbufferProjectionInverse*vec4(v.x*2.f-1.f,v.y*2.f-1.f,2.f*y-1.f,1.f);
   f/=f.w;
   return f;
 }
 void G(inout vec3 v,in vec3 y,in vec3 f,vec3 z,float x)
 {
   float r=length(y);
   r*=pow(eyeBrightnessSmooth.y/240.f,6.f);
   r*=rainStrength;
   float i=pow(exp(-r*1e-05),4.);
   i=max(i,.5);
   vec3 c=vec3(dot(colorSkyUp,vec3(1.)))*.05;
   v=mix(c,v,vec3(i));
 }
 vec4 G(float v,float y,vec3 s,vec3 t,vec3 x,vec3 z,vec3 w,float m,float n)
 {
   float a=1.;
   #ifdef SUNLIGHT_LEAK_FIX
   if(isEyeInWater<1)
     a=saturate(n*100.);
   #endif
   v=max(v-.05,0.);
   y=0.;
   float h=v*v,l=fract(frameCounter*.0123456);
   vec3 R=c(texcoord.xy).xyz*.99+.005,p=c(texcoord.xy+.1).xyz,o=reflect(w,c(c(texcoord.xy).xy*vec2(1.,.8),h,x)),T=normalize((gbufferModelView*vec4(o.xyz,0.)).xyz);
   if(dot(o,x)<0.)
     o=reflect(o,x);
   #ifdef REFLECTION_SCREEN_SPACE_TRACING
   bool g=false;
   {
     const int q=16;
     vec2 b=texcoord.xy;
     vec3 D=t.xyz;
     float W=0.;
     vec3 N=t.xyz;
     float P=.1/saturate(dot(-w,x)+.001),U=P*2.,k=1.,Y=0.;
     for(int S=0;S<q;S++)
       {
         float I=float(S),E=(I+.5)/float(q);
         vec3 F=T.xyz*P*(.1+length(N)*.1)*k;
         float O=U*(length(N)*.1);
         N+=F;
         vec2 C=ProjectBack(N).xy;
         vec3 M=GetViewPosition(C.xy,GetDepth(C.xy)).xyz;
         float V=length(N)-length(M)-.02;
         if(N.z>0.)
           {
             break;
           }
         if(V>0.&&V<O&&C.x>0.&&C.x<1.&&C.y>0.&&C.y<1.)
           {
             N-=F;
             k*=.5;
             Y+=1.;
             if(Y>2.)
               {
                 g=true;
                 b=C.xy;
                 D=M.xyz;
                 W=distance(N,t.xyz)*.4;
                 break;
               }
           }
       }
     vec3 S=(gbufferModelViewInverse*vec4(D,0.)).xyz;
     if(length(S)>far)
       g=false;
     if(g)
       {
         b.xy=floor(b.xy*vec2(viewWidth,viewHeight)+.5)/vec2(viewWidth,viewHeight);
         TemporalJitterProjPos01(b);
         vec3 F=pow(texture2DLod(colortex3,b.xy,0).xyz,vec3(2.2)),E=F*100.;
         LandAtmosphericScattering(E,D-t,T,o,worldSunVector,1.);
         G(E,D,normalize(t.xyz),normalize(s.xyz),1.);
         if(isEyeInWater>0)
           E*=1.2,UnderwaterFog(E,length(D),w,colorSkyUp,colorSunlight),E/=1.2;
         return vec4(E,saturate(W/4.));
       }
   }
   #endif
   int N=f(),E=d();
   vec3 q=s+x*(.01+m*.1);
   q+=Fract01(cameraPosition.xyz+.5);
   Ray D=MakeRay(e(q,N)*N-vec3(1.),o);
   vec3 S=vec3(1.),b=vec3(0.);
   float W=0.;
   qconKIZlZt C=r(D);
   float U=far;
   vec3 M=vec3(1.);
   for(int F=0;F<1;F++)
     {
       vec4 P=vec4(0.);
       vec3 I=vec3(0.);
       float Y=.5;
       for(int V=0;V<REFLECTION_TRACE_LENGTH;V++)
         {
           I=C.pnOlPKItYq/float(N);
           vec2 O=d(I,N);
           P=texture2DLod(shadowcolor,O,0);
           W=P.w*255.;
           float k=1.-step(.5,abs(W-241.));
           vec3 u=P.xyz;
           float L=dot(C.pnOlPKItYq+.5-D.origin,C.pnOlPKItYq+.5-D.origin),H=saturate(pow(saturate(dot(D.direction,normalize(C.pnOlPKItYq+.5-D.origin))),56.*L)*5.-1.)*5.;
           b+=u*k*Y*.5*H;
           if(W<240.)
             {
               if(G(C.pnOlPKItYq,W,D,V==0,U,M))
                 {
                   break;
                 }
             }
           i(C);
           Y=1.;
         }
       if(P.w*255.<1.f||P.w*255.>254.f)
         {
           vec3 V=SkyShading(D.direction,worldSunVector,rainStrength);
           V=DoNightEyeAtNight(V*12.,timeMidnight)*.083333;
           vec3 k=V*S,O=k;
           #ifdef CLOUDS_IN_GI
           CloudPlane(O,-D.direction,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,k,timeMidnight,false);
           k=mix(k,O,vec3(a));
           #endif
           k=TintUnderwaterDepth(k);
           b+=k*.1;
           U=1000.;
           break;
         }
       vec3 V=mod(D.origin+D.direction*U,vec3(1.))-.5;
       float k=log2(U*.4*v*TEXTURE_RESOLUTION);
       vec2 O=vec2(0.);
       O+=vec2(V.z*-M.x,-V.y)*abs(M.x);
       O+=vec2(V.x,V.z*M.y)*abs(M.y);
       O+=vec2(V.x*M.z,-V.y)*abs(M.z);
       vec3 u=(D.origin+D.direction*U)/float(N);
       vec2 L=textureSize(colortex0,0);
       vec4 H=texture2DLod(shadowcolor1,d(I,N),0);
       vec2 A=H.xy;
       A=(floor(A*L/TEXTURE_RESOLUTION)+.5)/(L/TEXTURE_RESOLUTION);
       vec2 B=A+O.xy*(TEXTURE_RESOLUTION/L);
       vec3 j=pow(texture2DLod(colortex0,B,k).xyz,vec3(2.2));
       j*=mix(vec3(1.),P.xyz/(H.w+1e-05),vec3(H.z));
       if(W<240.)
         {
           vec3 Z=saturate(P.xyz);
           S*=j;
         }
       if(abs(W-31.)<.1)
         b+=.09*S*GI_LIGHT_BLOCK_INTENSITY;
       if(U*v>.2)
         {
           vec3 Z=vec3(1.)-abs(M);
           b+=c(I+(V+(p.xyz-.5)*2.)/float(N)*Z,M)*S;
         }
       else
         {
           vec3 Z=vec3(0.),K=vec3(0.);
           if(abs(M.x)>.5)
             Z=vec3(0.,1.,0.),K=vec3(0.,0.,1.);
           if(abs(M.y)>.5)
             Z=vec3(1.,0.,0.),K=vec3(0.,0.,1.);
           if(abs(M.z)>.5)
             Z=vec3(1.,0.,0.),K=vec3(0.,1.,0.);
           Z*=1.;
           K*=1.;
           vec3 X=c(I,M),J=X,Q=saturate(X*100000.),ab=c(I+Z/float(N),M);
           J+=ab;
           Q+=saturate(ab*100000.);
           vec3 ac=c(I-Z/float(N),M);
           J+=ac;
           Q+=saturate(ac*100000.);
           vec3 ad=c(I+K/float(N),M);
           J+=ad;
           Q+=saturate(ad*100000.);
           vec3 ae=c(I-K/float(N),M);
           J+=ae;
           Q+=saturate(ae*100000.);
           J/=Q+vec3(.0001);
           b+=J*S;
         }
       const float Z=2.4;
       vec3 K=e(q+D.direction*U-1.,worldLightVector,M,o,N)*S*Z*colorSunlight*a;
       if(isEyeInWater>0)
         ;
       b+=K;
     }
   vec3 V=t.xyz+T*U,k=(gbufferModelViewInverse*vec4(V.xyz,0.)).xyz;
   if(U<1000.)
     LandAtmosphericScattering(b,V-t,T,o,worldSunVector,1.);
   if(isEyeInWater>0)
     b*=1.2,UnderwaterFog(b,length(k),w,colorSkyUp,colorSunlight),b/=1.2;
   U*=saturate(dot(-w,x))*2.;
   return vec4(b,saturate(U/4.));
 }
 vec4 T(float v)
 {
   float y=v*v,f=y*v;
   vec4 i;
   i.x=-f+3*y-3*v+1;
   i.y=3*f-6*y+4;
   i.z=-3*f+3*y+3*v+1;
   i.w=f;
   return i/6.f;
 }
 vec4 T(in sampler2D v,in vec2 f)
 {
   vec2 y=vec2(viewWidth,viewHeight);
   f*=y;
   f-=.5;
   float x=fract(f.x),i=fract(f.y);
   f.x-=x;
   f.y-=i;
   vec4 c=T(x),t=T(i),r=vec4(f.x-.5,f.x+1.5,f.y-.5,f.y+1.5),s=vec4(c.x+c.y,c.z+c.w,t.x+t.y,t.z+t.w),d=r+vec4(c.y,c.w,t.y,t.w)/s,z=texture2DLod(v,vec2(d.x,d.z)/y,0),w=texture2DLod(v,vec2(d.y,d.z)/y,0),o=texture2DLod(v,vec2(d.x,d.w)/y,0),a=texture2DLod(v,vec2(d.y,d.w)/y,0);
   float n=s.x/(s.x+s.y),N=s.z/(s.z+s.w);
   return mix(mix(a,o,n),mix(w,z,n),N);
 }
 bool i(vec3 v,vec3 y)
 {
   vec3 f=normalize(cross(dFdx(v),dFdy(v))),x=normalize(y-v),i=normalize(x);
   return distance(v,y)<.05;
 }
 vec3 a(vec2 v)
 {
   vec2 y=vec2(viewWidth,viewHeight),x=1./y,f=v*y,i=floor(f-.5)+.5,c=f-i,z=c*c,t=c*z;
   float s=.5;
   vec2 d=-s*t+2.*s*z-s*c,r=(2.-s)*t-(3.-s)*z+1.,w=-(2.-s)*t+(3.-2.*s)*z+s*c,a=s*t-s*z,n=r+w,M=x*(i+w/n);
   vec3 m=texture2DLod(colortex4,vec2(M.x,M.y),0).xyz;
   vec2 V=x*(i-1.),D=x*(i+2.);
   vec4 o=vec4(texture2DLod(colortex4,vec2(M.x,V.y),0).xyz,1.)*(n.x*d.y)+vec4(texture2DLod(colortex4,vec2(V.x,M.y),0).xyz,1.)*(d.x*n.y)+vec4(m,1.)*(n.x*n.y)+vec4(texture2DLod(colortex4,vec2(D.x,M.y),0).xyz,1.)*(a.x*n.y)+vec4(texture2DLod(colortex4,vec2(M.x,D.y),0).xyz,1.)*(n.x*a.y);
   return max(vec3(0.),o.xyz*(1./o.w));
 }
 void main()
 {
   GBufferData v=GetGBufferData();
   GBufferDataTransparent f=GetGBufferDataTransparent();
   MaterialMask y=CalculateMasks(v.materialID),i=CalculateMasks(f.materialID);
   bool x=f.depth<v.depth;
   if(x)
     v.depth=f.depth,v.normal=f.normal,v.smoothness=f.smoothness,v.metalness=0.,v.mcLightmap=f.mcLightmap,i.sky=0.;
   vec4 r=GetViewPosition(texcoord.xy,v.depth),t=gbufferModelViewInverse*vec4(r.xyz,1.),d=gbufferModelViewInverse*vec4(r.xyz,0.);
   vec3 c=normalize(r.xyz),s=normalize(d.xyz),z=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz),w=normalize((gbufferModelViewInverse*vec4(v.geoNormal,0.)).xyz);
   float m=length(r.xyz);
   vec4 n=vec4(0.);
   float a=G(v.smoothness,v.metalness);
   if(a>.0001&&i.sky<.5)
     n=G(1.-v.smoothness,v.metalness,t.xyz,r.xyz,z.xyz,w,s.xyz,y.leaves,v.mcLightmap.y);
   vec4 V=texture2DLod(colortex3,texcoord.xy,0);
   vec3 M=V.xyz;
   M.xyz=pow(M.xyz,vec3(2.2));
   if(x)
     {
       vec3 D=GetViewPosition(texcoord.xy,texture2DLod(depthtex1,texcoord.xy,0).x).xyz;
       float e=length(D.xyz),b=e-m;
       vec3 C=f.normal-f.geoNormal*1.05;
       float k=saturate(b*.5);
       vec2 o=texcoord.xy+C.xy/(m+1.5)*k;
       {
         float N=ExpToLinearDepth(texture2DLod(depthtex1,o,0).x),l=ExpToLinearDepth(texture2DLod(depthtex0,o,0).x);
         if(l>=N)
           o=texcoord.xy;
       }
       M.xyz=pow(texture2DLod(colortex3,o.xy,0).xyz,vec3(2.2));
       D=GetViewPosition(o.xy,texture2DLod(depthtex1,o.xy,0).x).xyz;
       r=GetViewPosition(o.xy,texture2DLod(depthtex0,o.xy,0).x);
       e=length(D.xyz);
       m=length(r.xyz);
       b=e-m;
       if(i.water>.5&&isEyeInWater<1)
         M.xyz*=100.,UnderwaterFog(M.xyz,b,s,colorSkyUp,colorSunlight),M.xyz*=.01;
       if(i.stainedGlass>.5)
         {
           vec3 h=normalize(f.albedo.xyz+.0001)*pow(length(f.albedo.xyz),.5);
           M.xyz*=mix(vec3(1.),h,vec3(pow(f.albedo.w,.2)));
           M.xyz*=mix(vec3(1.),h,vec3(pow(f.albedo.w,.2)));
         }
     }
   M.xyz=pow(M.xyz,vec3(1./2.2));
   gl_FragData[0]=texture2DLod(colortex0,texcoord.xy,0);
   gl_FragData[1]=vec4(M.xyz,v.smoothness);
   gl_FragData[2]=n*vec4(vec3(.1),1.);
 };




/* DRAWBUFFERS:036 */

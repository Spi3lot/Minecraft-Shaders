#version 330 compatibility

layout(triangles) in;
layout(triangle_strip, max_vertices = 6) out;


in VS_OUT {
    vec3 entity;
    vec4 glcolor;
    vec4 glvertex;
    vec4 texcoord;
    vec4 lmcoord;
    mat4 modelView;
    vec4 viewPos;
} gs_in[];

out GS_OUT {
	vec3 entity;
    vec4 glcolor;
    vec4 glvertex;
    vec4 texcoord;
    vec4 lmcoord;
    mat4 modelView;
    vec4 viewPos;
} gs_out;


void main() {
	for (int i = 0; i < 3; i++) {
		gl_Position = gl_in[i].gl_Position;
		gs_out.entity = gs_in[i].entity;
	    gs_out.glcolor = gs_in[i].glcolor;
	    gs_out.glvertex = gs_in[i].glvertex;  // Unmodified vertex
	    gs_out.texcoord = gs_in[i].texcoord;
	    gs_out.lmcoord = gs_in[i].lmcoord;
	    gs_out.modelView = gs_in[i].modelView;
	    gs_out.viewPos = gs_in[i].viewPos;
		EmitVertex();
	}

	EndPrimitive();

	/*
	//if (gs_out.entity.x == 9) {
		vec4 A, B, C, AB, AC, BC;
		A = gl_in[0].gl_Position;
		B = gl_in[1].gl_Position;
		C = gl_in[2].gl_Position;
		AB = mix(A, B, 0.5);
		AC = mix(A, C, 0.5);
		BC = mix(B, C, 0.5);

		gs_out.entity = gs_in[0].entity;
	    gs_out.glcolor = gs_in[0].glcolor;
	    gs_out.glvertex = gs_in[0].glvertex;  // Unmodified vertex
	    gs_out.texcoord = gs_in[0].texcoord;
	    gs_out.lmcoord = gs_in[0].lmcoord;
	    gs_out.modelView = gs_in[0].modelView;
	    gs_out.viewPos = gs_in[0].viewPos;
		gl_Position = A;
		EmitVertex();

	    gs_out.entity = gs_in[2].entity;
	    gs_out.glcolor = gs_in[2].glcolor;
	    gs_out.glvertex = gs_in[2].glvertex;  // Unmodified vertex
	    gs_out.texcoord = gs_in[2].texcoord;
	    gs_out.lmcoord = gs_in[2].lmcoord;
	    gs_out.modelView = gs_in[2].modelView;
	    gs_out.viewPos = gs_in[2].viewPos;
		gl_Position = C;
		EmitVertex();

		gs_out.entity = mix(gs_in[0].entity, gs_in[1].entity, 0.5);
	    gs_out.glcolor = mix(gs_in[0].glcolor, gs_in[1].glcolor, 0.5);
	    gs_out.glvertex = mix(gs_in[0].glvertex, gs_in[1].glvertex, 0.5);  // Unmodified vertex
	    gs_out.texcoord = mix(gs_in[0].texcoord, gs_in[1].texcoord, 0.5);
	    gs_out.lmcoord = mix(gs_in[0].lmcoord, gs_in[1].lmcoord, 0.5);
	    gs_out.viewPos = mix(gs_in[0].viewPos, gs_in[1].viewPos, 0.5);
		gl_Position = AB;
		EmitVertex();

	    gs_out.entity = mix(gs_in[1].entity, gs_in[2].entity, 0.5);
	    gs_out.glcolor = mix(gs_in[1].glcolor, gs_in[2].glcolor, 0.5);
	    gs_out.glvertex = mix(gs_in[1].glvertex, gs_in[2].glvertex, 0.5);  // Unmodified vertex
	    gs_out.texcoord = mix(gs_in[1].texcoord, gs_in[2].texcoord, 0.5);
	    gs_out.lmcoord = mix(gs_in[1].lmcoord, gs_in[2].lmcoord, 0.5);
	    gs_out.viewPos = mix(gs_in[1].viewPos, gs_in[2].viewPos, 0.5);
		gl_Position = BC;
		EmitVertex();

		gs_out.entity = gs_in[1].entity;
	    gs_out.glcolor = gs_in[1].glcolor;
	    gs_out.glvertex = gs_in[1].glvertex;  // Unmodified vertex
	    gs_out.texcoord = gs_in[1].texcoord;
	    gs_out.lmcoord = gs_in[1].lmcoord;
	    gs_out.modelView = gs_in[1].modelView;
	    gs_out.viewPos = gs_in[1].viewPos;
		gl_Position = B;
		EmitVertex();
	//}

	EndPrimitive();
	*/
}

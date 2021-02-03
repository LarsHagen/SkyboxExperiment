// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ProceduralSpace"
{
	Properties
	{
		_Seed("Seed", Float) = 1
		_NumStars("NumStars", Range( 0 , 1)) = 0.5
		_StarColor1("StarColor1", Color) = (1,0.7294118,0.7294118,1)
		_StarColor2("StarColor2", Color) = (0.7411765,0.764706,1,1)
		_DustAmount("DustAmount", Range( 0 , 1)) = 0.5
		_Nebular1Strength("Nebular 1 Strength", Range( 0 , 1)) = 0.7411765
		_Nebular1ColorMain("Nebular1ColorMain", Color) = (0.245283,0.08214667,0.08214667,0)
		_Nebular1ColorMid("Nebular1ColorMid", Color) = (0.6839622,0.7408348,1,0)
		_Nebular2Strength("Nebular2Strength", Range( 0 , 1)) = 0
		_Nebular2Color1("Nebular2Color1", Color) = (0.08884287,1,0,0)
		_Nebular2Color2("Nebular2Color2", Color) = (0.928674,1,0,0)
		_Sunsize("Sun size", Range( 0 , 1)) = 0
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		

		Pass
		{
			Name "Unlit"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#include "UnityStandardBRDF.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			uniform float _Seed;
			uniform float _DustAmount;
			uniform float _NumStars;
			uniform float4 _StarColor1;
			uniform float4 _StarColor2;
			uniform float _Nebular1Strength;
			uniform float4 _Nebular1ColorMain;
			uniform float4 _Nebular1ColorMid;
			uniform float4 _Nebular2Color1;
			uniform float4 _Nebular2Color2;
			uniform float _Nebular2Strength;
			uniform float _Sunsize;
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord = v.vertex;
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
				float3 appendResult78 = (float3(_Seed , 0.0 , _Seed));
				float3 Position79 = ( appendResult78 + i.ase_texcoord.xyz );
				float simplePerlin3D42 = snoise( ( Position79 * 1.0 ) );
				float simplePerlin3D44 = snoise( ( Position79 * 5.0 ) );
				float lerpResult29 = lerp( -0.6 , -0.9 , ( 1.0 - _NumStars ));
				float simplePerlin3D19 = snoise( ( Position79 * 80.0 ) );
				float smoothstepResult25 = smoothstep( lerpResult29 , -1.0 , simplePerlin3D19);
				float simplePerlin2D36 = snoise( ( Position79 * 2.0 ).xy );
				float4 lerpResult40 = lerp( _StarColor1 , _StarColor2 , (simplePerlin2D36*0.5 + 0.5));
				float4 color249 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float simplePerlin3D56 = snoise( ( Position79 * 0.4 ) );
				float temp_output_108_0 = abs( simplePerlin3D56 );
				float lerpResult234 = lerp( 0.0 , 0.1 , _Nebular1Strength);
				float lerpResult223 = lerp( 15.0 , 5.0 , _Nebular1Strength);
				float simplePerlin3D105 = snoise( ( Position79 * 2.0 ) );
				float lerpResult231 = lerp( 0.5 , 1.0 , _Nebular1Strength);
				float simplePerlin3D188 = snoise( ( Position79 * 5.0 ) );
				float simplePerlin3D192 = snoise( ( Position79 * 10.0 ) );
				float simplePerlin3D204 = snoise( ( Position79 * 150.0 ) );
				float temp_output_201_0 = ( (simplePerlin3D105*0.5 + lerpResult231) + simplePerlin3D188 + ( simplePerlin3D192 * 0.5 ) + ( simplePerlin3D204 * 0.05 ) );
				float lerpResult232 = lerp( 30.0 , 15.0 , _Nebular1Strength);
				float clampResult218 = clamp( ( pow( ( 1.0 - temp_output_108_0 ) , lerpResult232 ) * temp_output_201_0 ) , 0.0 , 1.0 );
				float4 lerpResult215 = lerp( ( pow( ( 1.0 - ( temp_output_108_0 - lerpResult234 ) ) , lerpResult223 ) * temp_output_201_0 * _Nebular1ColorMain ) , _Nebular1ColorMid , clampResult218);
				float clampResult251 = clamp( ( _Nebular1Strength * 10.0 ) , 0.0 , 1.0 );
				float4 lerpResult248 = lerp( color249 , lerpResult215 , clampResult251);
				float4 color259 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float simplePerlin3D171 = snoise( ( ( Position79 + 100.0 ) * 0.9 ) );
				float simplePerlin3D172 = snoise( ( Position79 * 0.9 ) );
				float4 lerpResult258 = lerp( color259 , ( ( (simplePerlin3D171*1.0 + 0.5) * _Nebular2Color1 * 0.2 ) + ( (simplePerlin3D172*1.0 + 0.5) * _Nebular2Color2 * 0.2 ) ) , _Nebular2Strength);
				#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float temp_output_340_0 = ( 1.0 - _Sunsize );
				float lerpResult315 = lerp( 0.5 , 0.99 , temp_output_340_0);
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(ase_worldPos));
				float3 uv307 = i.ase_texcoord2.xyz;
				uv307.xy = i.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_297_0 = ( 1.0 - length( ( worldSpaceLightDir - uv307 ) ) );
				float smoothstepResult299 = smoothstep( ( lerpResult315 - 0.01 ) , lerpResult315 , temp_output_297_0);
				float smoothstepResult330 = smoothstep( lerpResult315 , 1.0 , temp_output_297_0);
				float lerpResult331 = lerp( 5.0 , 15.0 , temp_output_340_0);
				float simplePerlin3D323 = snoise( ( Position79 * lerpResult331 ) );
				float4 lerpResult301 = lerp( ( ( (( simplePerlin3D42 + simplePerlin3D44 )*0.1 + _DustAmount) * 0.1 ) + ( smoothstepResult25 * lerpResult40 ) + lerpResult248 + lerpResult258 ) , ase_lightColor , ( smoothstepResult299 + ( smoothstepResult330 * ( simplePerlin3D323 * 0.2 ) ) ));
				float lerpResult318 = lerp( 0.2 , 1.0 , temp_output_340_0);
				float smoothstepResult309 = smoothstep( ( lerpResult318 - 0.2 ) , lerpResult318 , temp_output_297_0);
				float lerpResult320 = lerp( 0.1 , 0.5 , temp_output_340_0);
				
				
				finalColor = ( lerpResult301 + ( ( smoothstepResult309 * lerpResult320 ) * ( ase_lightColor / 3.0 ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16100
-1876;41;1836;897;1754.239;-406.757;1.008929;True;True
Node;AmplifyShaderEditor.RangedFloatNode;76;-2407.647,70.52687;Float;False;Property;_Seed;Seed;0;0;Create;True;0;0;False;0;1;900;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;78;-2176.799,107.1703;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;80;-2279.475,280.1664;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-2000.475,175.1664;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1844.369,1275.792;Float;False;2245.135;1274.186;Nebular 1;43;233;230;215;212;208;218;214;132;134;211;109;201;223;205;206;207;232;188;210;133;186;105;234;204;192;108;231;190;203;104;219;56;228;227;202;65;189;85;222;249;250;248;251;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-1862.297,210.8592;Float;False;Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-1753.238,1325.127;Float;False;79;Position;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;222;-1477.035,1397.593;Float;False;Constant;_Float4;Float 4;9;0;Create;True;0;0;False;0;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1300.07,1332.772;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;160;-1861.914,2687.113;Float;False;2159.649;1018.096;Nebular 2;21;183;182;181;180;179;178;176;175;174;172;171;170;168;167;165;162;256;255;258;259;260;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-1488.063,1816.944;Float;False;Constant;_Float14;Float 14;4;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-1490.23,1918.431;Float;False;Constant;_Float15;Float 15;4;0;Create;True;0;0;False;0;150;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;-1470.092,1615.896;Float;False;Constant;_Float5;Float 5;9;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-1321.76,1880.159;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-1319.592,1778.671;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-1784.18,2109.588;Float;False;Property;_Nebular1Strength;Nebular 1 Strength;5;0;Create;True;0;0;False;0;0.7411765;0.079;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;56;-1107.704,1307.566;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-1482.092,1702.896;Float;False;Constant;_Float6;Float 6;9;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;313;591.7161,2459.749;Float;False;2561.926;1234.284;Sun;10;334;308;297;296;272;312;307;288;335;340;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-1849.981,2938.643;Float;False;79;Position;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;256;-1831.063,2865.599;Float;False;Constant;_offset;offset;9;0;Create;True;0;0;False;0;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1305.383,1568.566;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1302.552,1670.082;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;192;-1160.45,1785.919;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;204;-1162.618,1887.407;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;34;-1567.919,485.6254;Float;False;1479.028;734.2823;Stars;16;17;23;26;19;29;25;30;31;35;36;37;38;39;40;84;341;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;105;-1146.24,1577.589;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-1520.035,3194.812;Float;False;Constant;_Float10;Float 10;4;0;Create;True;0;0;False;0;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;231;-1085.961,1663.264;Float;False;3;0;FLOAT;0.5;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;678.8533,3049.785;Float;False;Property;_Sunsize;Sun size;11;0;Create;True;0;0;False;0;0;0.192;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;167;-1479.382,2810.883;Float;False;Constant;_Float11;Float 11;4;0;Create;True;0;0;False;0;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-1564.384,-117.8735;Float;False;1474.568;541.9702;Dust;11;42;44;45;46;47;48;49;51;53;55;82;;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;108;-918.0895,1326.876;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;234;-813.7988,1523.693;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;255;-1633.801,2825.966;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1344.7,262.0616;Float;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;340;987.22,3052.967;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;232;-665.4997,2213.277;Float;False;3;0;FLOAT;30;False;1;FLOAT;15;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;133;-738.1016,1353.319;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1341.301,164.5613;Float;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;288;616.4944,2586.375;Float;True;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;188;-1164.147,1698.067;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;-920.569,1870.632;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;210;-655.9313,1975.551;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1310.913,2772.61;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;307;623.86,2787.458;Float;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;82;-1362.475,38.16641;Float;False;79;Position;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;207;-899.616,1628.406;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1318.54,1118.908;Float;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-1346.646,3156.431;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-962.1689,1774.953;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;334;1284.348,3071.216;Float;False;1360.131;555.2634;Inner;11;328;299;324;317;330;332;315;323;325;327;331;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-1322.463,656.2975;Float;False;79;Position;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;331;1318.62,3498.462;Float;False;3;0;FLOAT;5;False;1;FLOAT;15;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;272;894.8848,2591.004;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;171;-1151.77,2779.858;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;109;-589.2109,1361.838;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;211;-460.3045,1972.503;Float;True;2;0;FLOAT;0;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1094.512,-11.5631;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;201;-659.8298,1706.044;Float;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;223;-588.2827,1571.279;Float;False;3;0;FLOAT;15;False;1;FLOAT;5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;172;-1179.704,3164.979;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1157.34,1059.107;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1552.324,533.1628;Float;False;Property;_NumStars;NumStars;1;0;Create;True;0;0;False;0;0.5;0.714;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1095.312,144.4369;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1308.579,733.6851;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;80;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;327;1465.561,3391.148;Float;False;79;Position;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;176;-1798.153,3064.349;Float;False;Property;_Nebular2Color1;Nebular2Color1;9;0;Create;True;0;0;False;0;0.08884287,1,0,0;0.04940557,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-177.1474,1990.031;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;175;-1803.87,3325.854;Float;False;Property;_Nebular2Color2;Nebular2Color2;10;0;Create;True;0;0;False;0;0.928674,1,0,0;0,0.9388056,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;179;-914.2575,3084.867;Float;False;Constant;_Float13;Float 13;4;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;36;-1028.637,1063.007;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1096.923,707.3146;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;134;-1750.842,2188.577;Float;False;Property;_Nebular1ColorMain;Nebular1ColorMain;6;0;Create;True;0;0;False;0;0.245283,0.08214667,0.08214667,0;0.1856521,0.7176471,0.08627451,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;335;1889.422,2537.678;Float;False;758.7218;485.4104;Glow;8;320;314;337;338;339;309;319;318;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;180;-971.2572,3189.573;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;341;-1283.426,544.4313;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-919.7774,3437.061;Float;False;Constant;_Float12;Float 12;4;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;178;-923.8238,2794.051;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;296;1144.467,2627.547;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;325;1685.147,3406.009;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;42;-934.2993,-57.11499;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;44;-941.0794,166.1232;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;132;-369.7943,1378.902;Float;True;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;318;1939.022,2606.386;Float;False;3;0;FLOAT;0.2;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-652.6233,2900.695;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;29;-1086.399,538.3727;Float;False;3;0;FLOAT;-0.6;False;1;FLOAT;-0.9;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-1515.415,961.1363;Float;False;Property;_StarColor2;StarColor2;3;0;Create;True;0;0;False;0;0.7411765,0.764706,1,1;0.7216981,0.9919894,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;297;1351.971,2673.579;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;212;-1732.608,2360.68;Float;False;Property;_Nebular1ColorMid;Nebular1ColorMid;7;0;Create;True;0;0;False;0;0.6839622,0.7408348,1,0;0.8709545,1,0.7216981,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;30;-1514.135,792.8828;Float;False;Property;_StarColor1;StarColor1;2;0;Create;True;0;0;False;0;1,0.7294118,0.7294118,1;0.995312,1,0.7783019,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;315;1478.733,3200.891;Float;False;3;0;FLOAT;0.5;False;1;FLOAT;0.99;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-650.6773,3225.161;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;39;-832.3371,1066.907;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1556.745,-80.61401;Float;False;Property;_DustAmount;DustAmount;4;0;Create;True;0;0;False;0;0.5;0.349;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-729.3358,58.75426;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;19;-958.0137,702.1146;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;323;1726.417,3506.724;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;218;-50.0094,2214.474;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;250;-375.4517,2408.36;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;19.4642,1599.035;Float;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;25;-732.451,657.3896;Float;False;3;0;FLOAT;0;False;1;FLOAT;-0.8;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;330;1823.078,3297.33;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;1940.158,3479.702;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;-353.9816,3030.794;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;319;1940.674,2730.21;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;317;1740.385,3118.715;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;51;-521.058,-56.39276;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;259;-360.0528,3352.96;Float;False;Constant;_Color1;Color 1;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;215;148.9573,2078.89;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;251;-193.1797,2416.848;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;249;-56.06409,2368.973;Float;False;Constant;_Color0;Color 0;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;260;-1815.493,3518.181;Float;False;Property;_Nebular2Strength;Nebular2Strength;8;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;-689.3382,903.1071;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-482.248,761.4102;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-319.3196,190.7361;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;308;1645.525,2512.256;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;320;2102.943,2750.201;Float;False;3;0;FLOAT;0.1;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;299;2089.522,3145.86;Float;True;3;0;FLOAT;0;False;1;FLOAT;0.95;False;2;FLOAT;0.97;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;258;-29.22401,3159.922;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;339;2160.853,2881.337;Float;False;Constant;_Float9;Float 9;11;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;2104.407,3372.511;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;248;200.9359,2352.973;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;309;2109.046,2632.161;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;338;2334.191,2758.997;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;328;2408.47,3229.847;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;1039.485,1338.526;Float;True;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;314;2312.603,2627.659;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;2488.757,2702.638;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;301;2572.81,1960.85;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;233;-853.0214,2035.095;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;230;-324.7403,1606.24;Float;False;3;0;FLOAT;1;False;1;FLOAT;3;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;333;2857.316,2112.108;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3118.482,2040.176;Float;False;True;2;Float;ASEMaterialInspector;0;1;ProceduralSpace;0770190933193b94aaa3065e307002fa;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;78;0;76;0
WireConnection;78;2;76;0
WireConnection;81;0;78;0
WireConnection;81;1;80;0
WireConnection;79;0;81;0
WireConnection;65;0;85;0
WireConnection;65;1;222;0
WireConnection;203;0;85;0
WireConnection;203;1;202;0
WireConnection;190;0;85;0
WireConnection;190;1;189;0
WireConnection;56;0;65;0
WireConnection;104;0;85;0
WireConnection;104;1;227;0
WireConnection;186;0;85;0
WireConnection;186;1;228;0
WireConnection;192;0;190;0
WireConnection;204;0;203;0
WireConnection;105;0;104;0
WireConnection;231;2;219;0
WireConnection;108;0;56;0
WireConnection;234;2;219;0
WireConnection;255;0;162;0
WireConnection;255;1;256;0
WireConnection;340;0;312;0
WireConnection;232;2;219;0
WireConnection;133;0;108;0
WireConnection;133;1;234;0
WireConnection;188;0;186;0
WireConnection;205;0;204;0
WireConnection;210;0;108;0
WireConnection;170;0;255;0
WireConnection;170;1;167;0
WireConnection;207;0;105;0
WireConnection;207;2;231;0
WireConnection;168;0;162;0
WireConnection;168;1;165;0
WireConnection;206;0;192;0
WireConnection;331;2;340;0
WireConnection;272;0;288;0
WireConnection;272;1;307;0
WireConnection;171;0;170;0
WireConnection;109;0;133;0
WireConnection;211;0;210;0
WireConnection;211;1;232;0
WireConnection;45;0;82;0
WireConnection;45;1;46;0
WireConnection;201;0;207;0
WireConnection;201;1;188;0
WireConnection;201;2;206;0
WireConnection;201;3;205;0
WireConnection;223;2;219;0
WireConnection;172;0;168;0
WireConnection;37;0;84;0
WireConnection;37;1;38;0
WireConnection;47;0;82;0
WireConnection;47;1;48;0
WireConnection;214;0;211;0
WireConnection;214;1;201;0
WireConnection;36;0;37;0
WireConnection;23;0;84;0
WireConnection;23;1;17;0
WireConnection;180;0;172;0
WireConnection;341;0;26;0
WireConnection;178;0;171;0
WireConnection;296;0;272;0
WireConnection;325;0;327;0
WireConnection;325;1;331;0
WireConnection;42;0;45;0
WireConnection;44;0;47;0
WireConnection;132;0;109;0
WireConnection;132;1;223;0
WireConnection;318;2;340;0
WireConnection;182;0;178;0
WireConnection;182;1;176;0
WireConnection;182;2;179;0
WireConnection;29;2;341;0
WireConnection;297;0;296;0
WireConnection;315;2;340;0
WireConnection;181;0;180;0
WireConnection;181;1;175;0
WireConnection;181;2;174;0
WireConnection;39;0;36;0
WireConnection;49;0;42;0
WireConnection;49;1;44;0
WireConnection;19;0;23;0
WireConnection;323;0;325;0
WireConnection;218;0;214;0
WireConnection;250;0;219;0
WireConnection;208;0;132;0
WireConnection;208;1;201;0
WireConnection;208;2;134;0
WireConnection;25;0;19;0
WireConnection;25;1;29;0
WireConnection;330;0;297;0
WireConnection;330;1;315;0
WireConnection;332;0;323;0
WireConnection;183;0;182;0
WireConnection;183;1;181;0
WireConnection;319;0;318;0
WireConnection;317;0;315;0
WireConnection;51;0;49;0
WireConnection;51;2;55;0
WireConnection;215;0;208;0
WireConnection;215;1;212;0
WireConnection;215;2;218;0
WireConnection;251;0;250;0
WireConnection;40;0;30;0
WireConnection;40;1;35;0
WireConnection;40;2;39;0
WireConnection;31;0;25;0
WireConnection;31;1;40;0
WireConnection;53;0;51;0
WireConnection;320;2;340;0
WireConnection;299;0;297;0
WireConnection;299;1;317;0
WireConnection;299;2;315;0
WireConnection;258;0;259;0
WireConnection;258;1;183;0
WireConnection;258;2;260;0
WireConnection;324;0;330;0
WireConnection;324;1;332;0
WireConnection;248;0;249;0
WireConnection;248;1;215;0
WireConnection;248;2;251;0
WireConnection;309;0;297;0
WireConnection;309;1;319;0
WireConnection;309;2;318;0
WireConnection;338;0;308;0
WireConnection;338;1;339;0
WireConnection;328;0;299;0
WireConnection;328;1;324;0
WireConnection;50;0;53;0
WireConnection;50;1;31;0
WireConnection;50;2;248;0
WireConnection;50;3;258;0
WireConnection;314;0;309;0
WireConnection;314;1;320;0
WireConnection;337;0;314;0
WireConnection;337;1;338;0
WireConnection;301;0;50;0
WireConnection;301;1;308;0
WireConnection;301;2;328;0
WireConnection;230;2;219;0
WireConnection;333;0;301;0
WireConnection;333;1;337;0
WireConnection;0;0;333;0
ASEEND*/
//CHKSM=47C4298FDA0E8FC46511300977BC2507643B55C6
#include once "inc/base64.bi"

function base64encode( decoded as const string ) as string

	dim as string encoded
	dim as integer six, n, a, b, c, k, padding

	static chars as string * 64 = _
	       "ABCDEFGHIJKLMNOPQRSTUVWXYZ" _
	       "abcdefghijklmnopqrstuvwxyz" _
	       "0123456789+/"

	encoded = ""
	for n = 1 to len( decoded ) step 3
		a = asc( mid( decoded, n + 0, 1 ) )
		b = asc( mid( decoded, n + 1, 1 ) )
		c = asc( mid( decoded, n + 2, 1 ) )
		padding = n + 2 - len( decoded )
		if padding < 0 then padding = 0
		for k = 0 to 3 - padding
			select case k
				case 0: six = ( ( &b11111100 and a ) shr 2 )
				case 1: six = ( ( &b00000011 and a ) shl 4 ) or ( ( b and &b11110000 ) shr 4 )
				case 2: six = ( ( &b00001111 and b ) shl 2 ) or ( ( c and &b11000000 ) shr 6 )
				case 3: six = ( ( &b00111111 and c ) )
			end select
			encoded += mid( chars, six+1, 1 )
		next k
	next n
	encoded += string( padding, "=" )

	return encoded

end function

' Accepts any padding character, not just '=', and also unpadded base64 strings.
' Returns "" if the input is invalid: contains any invalid character anywhere except the end.
' Newlines must be stripped by the caller.
function base64decode( encoded as const string ) as string

	dim as string decoded
	dim as integer eight, n, k, a, b, c, d

	static chars as string * 64 = _
	       "ABCDEFGHIJKLMNOPQRSTUVWXYZ" _
	       "abcdefghijklmnopqrstuvwxyz" _
	       "0123456789+/"

	decoded = ""
	for n = 1 to len( encoded ) step 4
		a = instr( chars, mid( encoded, n + 0, 1 ) ) - 1
		b = instr( chars, mid( encoded, n + 1, 1 ) ) - 1
		c = instr( chars, mid( encoded, n + 2, 1 ) ) - 1
		d = instr( chars, mid( encoded, n + 3, 1 ) ) - 1
		if ( a = -1 ) or ( b = -1 ) then return ""
		for k = 0 to 2
			select case k
				case 0: eight = ( ( &b111111 and a ) shl 2 ) or ( ( &b110000 and b ) shr 4 )
				case 1: if c = -1 then exit for, for
					eight = ( ( &b001111 and b ) shl 4 ) or ( ( &b111100 and c ) shr 2 )
				case 2: if d = -1 then exit for, for
					eight = ( ( &b000011 and c ) shl 6 ) or ( ( &b111111 and d ) shr 0 )
			end select
			decoded += chr( eight )
		next k
	next n
	' Was an invalid character encountered somewhere other than the end?
	' This test is inexact if the input is unpadded.
	' If there's no padding, expect len(decoded) = (3*len(encoded)) \ 4
	if len( decoded ) < (3 * (len( encoded ) - 2)) \ 4 then
		return ""
	end if
	return decoded

end function

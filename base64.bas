#include once "inc/base64.bi"

function base64encode( decoded as const string ) as string
	
	dim as string encoded, chars, lft, rgt, s
	dim as integer six, n, a, b, c, k
	
	chars = "abcdefghijklmnopqrstuvwxyz" _
	      + "ABCDEFGHIJKLMNOPQRSTUVWXYZ" _
	      + "1234567890&_"
	
	encoded = ""
	for n = 1 to len( decoded ) step 3
		a = asc( mid( decoded, n + 0, 1 ) )
		b = asc( mid( decoded, n + 1, 1 ) )
		c = asc( mid( decoded, n + 2, 1 ) )
		for k = 0 to 3
			select case k
				case 0: six = ( ( &b11111100 and a ) shr 2 )
				case 1: six = ( ( &b00000011 and a ) shl 4 ) or ( ( b and &b11110000 ) shr 4 )
				case 2: six = ( ( &b00001111 and b ) shl 2 ) or ( ( c and &b11000000 ) shr 6 )
				case 3: six = ( ( &b00111111 and c ) )
			end select
			encoded += mid( chars, six+1, 1 )
		next k
	next n
	
	return encoded
	
end function

function base64decode( encoded as const string ) as string
	
	dim as string decoded, chars
	dim as integer eight, n, k, a, b, c, d
	
	chars = "abcdefghijklmnopqrstuvwxyz" _
	      + "ABCDEFGHIJKLMNOPQRSTUVWXYZ" _
	      + "1234567890&_"
	
	decoded = ""
	for n = 1 to len( encoded ) step 4
		a = instr( chars, mid( encoded, n + 0, 1 ) ) - 1
		b = instr( chars, mid( encoded, n + 1, 1 ) ) - 1
		c = instr( chars, mid( encoded, n + 2, 1 ) ) - 1
		d = instr( chars, mid( encoded, n + 3, 1 ) ) - 1
		if ( a = -1 ) or ( b = -1 ) or ( c = -1 ) or ( d = -1 ) then
			decoded += "ERR"
			continue for
		end if
		for k = 0 to 2
			select case k
				case 0: eight = ( ( &b111111 and a ) shl 2 ) or ( ( &b110000 and b ) shr 4 )
				case 1: eight = ( ( &b001111 and b ) shl 4 ) or ( ( &b111100 and c ) shr 2 )
				case 2: eight = ( ( &b000011 and c ) shl 6 ) or ( ( &b111111 and d ) shr 0 )
			end select
			decoded += chr( eight )
		next k
	next n
	
	return decoded
	
end function

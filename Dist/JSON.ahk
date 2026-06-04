;
; cJson.ahk 2.1.0-git-built
; Copyright (c) 2023 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/cJson.ahk
;
; 0BSD License
;
; Permission to use, copy, modify, and/or distribute this software for
; any purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL
; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
; FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
; DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
; AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
; OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;
#Requires AutoHotkey v2.0

class JSON
{
    static version := "2.1.0-git-built"

    /**
     * When true, Boolean values in the JSON will be decoded as numbers 1 and 0
     * for true and false respectively.
     *
     * When false, Boolean values in the JSON will be decoded as references to
     * {@link JSON.True} and {@link JSON.False} for true and false respectively.
     *
     * By default, this property is true.
     */
    static BoolsAsInts {
        get => this.lib.bBoolsAsInts
        set => this.lib.bBoolsAsInts := value
    }

    /**
     * When true, null values in the JSON will be decoded as ''.
     *
     * When false, null values in the JSON will be decoded as references to
     * {@link JSON.Null}.
     *
     * By default, this property is true.
     */
    static NullsAsStrings {
        get => this.lib.bNullsAsStrings
        set => this.lib.bNullsAsStrings := value
    }

    /**
     * When true, unicode values in the JSON will be encoded using backslash
     * escape sequences, such as '💩' will be encoded as "\ud83d\udca9". This
     * is to improve compatibility with external systems.
     *
     * When false, unicode values will be left as their original characters.
     *
     * By default, this property is true.
     */
    static EscapeUnicode {
        get => this.lib.bEscapeUnicode
        set => this.lib.bEscapeUnicode := value
    }

    /**
     * Utility function for the MCode to convert non-string values to string.
     */
    static fnCastString := Format.Bind('{}')

    /**
     * Constructor
     */
    static __New() {
        this.lib := this._LoadLib()

        ; Populate globals
        this.lib.objTrue := ObjPtr(this.True)
        this.lib.objFalse := ObjPtr(this.False)
        this.lib.objNull := ObjPtr(this.Null)

        this.lib.fnGetMap := ObjPtr(Map)
        this.lib.fnGetArray := ObjPtr(Array)

        this.lib.fnCastString := ObjPtr(this.fnCastString)
    }

    /**
     * Internal function to load the MCode
     */
	
	static _LoadLib32Bit() {
		static lib, code := Buffer(6396), codeB64 := ""
		. "jrkAV418JAiD5PgA/3f8ifhVieUAV1ZTgexQAQAAAIsfikgMi38ABItwCIiN3/4A//+LE4tIEIkEjdAAKGaD+gh0iGl/DgAcA3QiAAogBXRz6xAA"
		. "DgkPDIQ3AHYAEhR0LrpAMBQAAOkCAZZDAAiJRdDB+B+JAEXUjUXQiXQkAAiJfCQEiQQkCOgYFQAjHgIAAACDwwiJcAiJeAAEiRiNZfRbXgBfXY1n"
		. "+F/p+E8AQwUvAUYAMjEWADLrAQBWMcDyDxBLCCAxycdF2AAOAIkARcAx24lFxDGCwABniUXcjUUACBDQoXgSAJHHRcAABQCLEPIPEU0gyIlMJCAA"
		. "AxyNhE2wAAYYjU3QAAMgFMdEJBCCIlwkGgyAAQiAAYFQ/1IYADHAg+wki1W4AGaLFAJmhdIPBIRugBOF/3QMiwAPjVkCiR9miQAR6wL/BoPAAhTr"
		. "2QALIQALQQKJIAdmD76FAZxmiSABQooCiIIFhMAAdd3rBP8G6+2TgXeFgxwkBZO6QIB3SDsFjABZdSEAIAJghMAPhP+ASgo3AUEBN0Lr37pFghaE"
		. "VYoW0ZYWS4IWiIoWoxFVC42N4AF9EMeFmuTAAVCBYQBJMclAAVgQjY3BBABMDAJMTGQkCMACBJAAFgJMFASLlcEOg+wYg/pg/3VuumQADwhAQAmY"
		. "gwkTgSMPhAwEAYBDB41QAokXZpDHACIAwHWd1IAPaOkoCMIrFM9Ywy2XADHAD1fAx0W4AQOEtIlFvI2F8JFACIlFsMAdDxECA1KLAQIA/8ANx8ID"
		. "CDAAiY3YwAGAkoX47cAB3IAhRomNAQoDisGLwcNADIlUJASFjMABEghEP4uFwRH/UBiYjYUQwAHAIjHJQI/TRh8BBYsQAAIgQx/BA6AIAMeFGMAB"
		. "9Eod3wEISh0GqEAfRRyLQmnAHcUABQSAqo2FMFEdAQVcixCAGwECgRs4wAGc+4AbwAZA4wykDqQBvw6pDhFADWaDvcEkA3UNCIO9CAABAA+FQa0i"
		. "gb3hGMICKMMCNMMCEQENA3QHgkPrIoOEvUihA3Uu6+6gOyIkPGjpuv2gBQbrguqhG1fAjU2gwHs2dgAJwBlQQh1oVU3AWRhVVaDgBwRVMgxVDyyE"
		. "U8AMmU3ToitF0PyLCMVHBynhEKiLEymBSBuJRgApx2IBAKIA6cvngABgmQIC6woDAyEIQlzJgh6QiOFyRaCjPE8f7pBEHsIfSx8xQERjH4mlDwMa"
		. "4GcCqkFGRcADAFjHRcgBEpwbA61ETR6gSkTCKyA/gQcJdDQJCS3q+xwt/wbp+RFjBBuDveIgixcZAMCD4OCNSgKDgMB7iQ9miQJBBSS6lmAMgL2B"
		. "BwB0Eh2DnHQVEZzjD7aJYgwx26AgiZ3MAVoshcigAAApYGFoEYVScMIARYBgAJBgAKAGjSICQCKQDEAx2xFgLEWYjWMFEEWQGIlFiGCZgAOADEBR"
		. "ANGLhVijB9CAA4AIiV3EADNdzDHbq0QpAAPgx9CgYynADEVfANEGRaAog9HBeoVBoYUQwA+FGmAuZoN9IKADD4UVYeh9qFAAD4QLIQG9ARoAlHQ/"
		. "QB8OB6ksAI4kOl5EEj1PEkASVQI46yod8AEu9wFCYwN16VL/wgiLnXGBOTJaf6gLuplBPd0QOtijLYBIg/gBD4c8MW6BAhNmg/gDdRa7CVAiAOtZ"
		. "EANVsAEUHHUnvgHwCIFijYVok7En4GLpmzASupsyJbD4CXUlzx54DItiAxDrTrqk8wIIdS4nVoUTBcBn2A2xZXVkVOmBQ3EV7w7pwnvxxA+/YgyJ"
		. "hejADYFsNIXsgACN4gDpbDoMV4IEmwwRBCIXATqmGB8IjVAEIQFAAiAAUOsSiwYQAkC0AQ9ARcKJBouFQRZA+onwIYuiKqIG0D2DKUUHlCn2wACF"
		. "8R/pSgBMeRYXCXVgA7EOoCihJAic6xWSEFQBMQEVkDBh7FGLcy4UA3gfA1QBFgOuUtMuVQLyJVBVDViPGZGIGTHJOyKlfTFCIwVHQXQBJxSLH41D"
		. "hQpBA3MD10Hrx89ANcJAfcZAi6Ip2KTDkEyQjYA04a5x/MGuMQD/VlNRg+x0iwBxBIsZZscGFAAAiX4IiX4MvwATAIAAiwNmiwAQjUr3ZoP5FwB3"
		. "EA+jzw+DXhdgiWCeUAjiMK57D4UOUSAtAAGiVDH/iQP8oYDAOsE9cljkPXE94D0LAT/pPXzvPVIYi0UayIJ7tNIHQAYgfyMZ4bZ/BZCncHLqCbkB"
		. "sQkPo9EPg5kGRdUI0iACInQPUAB9aA+EobFjfbABsZUcYiQAIgToBSEhAENmN2ABzw3DDUrmBMENOg+chTkFAXAmQarov2RHxiCAAbEni0XYwgQh"
		. "BraLsJbAJ2zwmboFDLAFFHMRcwXmcAUsD4QBoX5mgzh9D4XXDgUUBtAD4BcJAOmmwxABUAJbD4WIoxWibrWzFXyzFdCyFbJnfCAW+HwkHNABd5lQ"
		. "MH+ZohWAfcgxwI1VvPIVSrwgorQAJ4sHMHgUhDHSUAAQjVW4poJyVKiCPCTwr4ByJxkllSIZC8LAExAL6x6IGYXVDtBAAl0PhK7hBC0EFH4BhQAU"
		. "33AkMdIJsH114GFk5IlF7KCLB8dF6KQHIDAAwhwwABiNVeDhCa+DOYALVbyACQGEc4Nmg4A+CXUdi0YIVTgQUOsPuhMJynMiI0MWdRmJVbSxGXbf"
		. "FbBjtAAZTAIZfbRdOA+FRRUu4hjQMOkXYxAB4SUPhWAwCDBJg4DABIkTiVYIEAKACACLC2aLEeIBLIQmgZ0REQEQA415iAKJO3ABXA+Foc0QZotR"
		. "AtAAZg+ECbFVfzKRAXRxfxiFcithUAAvD4XKwWyAx0D+LwDrdRABEGIPhbgUAQgA6yJjEAF0dFcSA250QkdQAHIPhZj0AQ0IAOtDEAF1D4WGgRAB"
		. "jVEEjXkMIApsfajBAdAZS3EAkFceIXEAXADrFnEADACE6w5xAAoA6wZxAAAJAIPBBIkL6wBajXm/ZoP/BQB3N4t9tI1MDwDJg8ICZolI/gCJEztV"
		. "qHQ8ZgCLeP7B5wRmiYB4/maLCmaJMAICeZAe/wl3x4tNALQB+evQjXmfMfEDD4f5gHgzBKnrILpmiVD+gBXpyxHRcnYIjdAAwQIpEPKJVvxDCokL"
		. "6RKt8AKNQsAE+AkPBJbBAA0tD5TACIDBiE2oD4TB8u4BI0pGCIlGDIsDGMdFtEEhkDQtdQxPoAXwAHAcgDJmiyFuMAx1EXAx4kyLA41IQgKgDVOD"
		. "6DEBXA8Mh16hCaAbOSS2AI1H0GaD+Al3ADhrRgwKg8ECAIlFsLgKAAAAAPdmCIkLiVWkAIlFoItFsAFFAKQPv8eZA0WgABNVpIPA0IPSAP+JRgiJ"
		. "VgzrELpmiwEAgC51QAkAeLoBAHKJC99uAAhmxwYFAN1eSAiLCwA+jXgAxv9gCXcda9ICxACuoADbRaBmiX2g3iB9oNxGCAAo69UIg+DfAEhFD4WG"
		. "gwBEAiZmgz4UdQpNAANmixBmg/otQHQKxkWoAAAJK0B1BYPAAokAFzgEjVcAZfoJD4eCKQCFMdIBEU8AEfkJIHcPa/oKACUPvwDRiQMB+uvlMQTJ"
		. "uAGoOcp+BmtAwApB6/bdgGVFAQFJgH2oAHQE3qD56wLeyYE3BoBIgBR1MItNtIsAERDLiU2oAAXB+x8AD69ODIldrIsAVawPr9AB0feQZbQBygOI"
		. "6eiALGGAGgUPhd6ABIAs2iRNtAAl6dCABrlAAhQBDvp0dUFmDwC+AYTAdBOLE0BmOwIPhc6BecIAAkGJE+vlgD0kbBIAB3QOAHsDAEjHRggBVutI"
		. "gAYJSAChjAAN6ZKBJUUVgyVmjiWCkCURMclBgiaJTggx0oHbRIUDJ4SADutGuUvDEihudUnEEg/CEnU6YcQR6YA9dMMRgA0IEAChlBPAeUYIMWjA"
		. "6x3DEYhABwAEiwAQiQQk/1IEUBDr5Lj/AACNZfAAWVteX12NYfz4w5CQwTHFAD8APwA/AAs/ABUAEMAATwB3AABuAFAAcgBvAChwAHPqDwjAAFAA"
		. "KnVADWjKBQbAAFMACGUAdMgEMDEyMwA0NTY3ODlBQhBDREVGYQKLFwAUAPRgAL5gABMYABQAo+AA2WAAIlVuAGtub3duX1ZhAGx1ZV8AdHJ1AGUA"
		. "ZmFsc2UAAG51bGwASABh1WAOTSIMaOAWZGAJZgaAT2JqZWN0XzEbil8gAEVgAnUAbaABwA0KAAkAIsUF5gcYVHlwQA7qGo1MJAAEg+T4MdL/cQD8"
		. "VYnlV4nPVgBTUYPsXIsxiwBZCIlVvI1VvECLBolUJBTAXlQgJBCNUQTAAAjHmEQkDKFQ4AAEkEFXADQk/1AUiwOLAFMMMcmD7BiJAE3EZolF0ItD"
		. "AUAI3I1VwIlF2ACLRwQx/4lNzAAxyYlF6I1F0AiJRcDAg8dF4AhgAMdFyAIBn6MMfFQkIGAAHGAAGMALEOoEIwMMYAEIQg0AFsINABiD7CRmgzsJ"
		. "zHUMwAwEZwhQKWZkGyMkG+AageyMQTMBixRxBCAP7kABeQiLAFAEiwCJwYnTBIHBYAOAg9MAgyD7AA+GkMEORagAjUWgMckx24kQRbSheIEPTaCJ"
		. "JE2kQBhVrCAOXbggiV3AMdtACaAUFYAYvKK3TMAXTCQcCI1NkMAAGI1NtI3AABQBGaIDXCQMYACKCGAABAIWGDHAwBgAi1WYZosUAmYghdIPhIXA"
		. "BIX2AHQMiw6NWQKJAB5miRHrAv8HkcCv69m5oIwAu6HLEIXAeSsCAZmJTUCMSff7uzBgASkA02aJXE3GhcAAdeSLTYyD6QIAZsdETcYtAOsEEJlA"
		. "BIPCMGaJAlTCA/AByY1EDULGYcGF0nQXsw3hGSApMcBmKSMog+wMAItdDIt9CIt1ABCF23QOiwONAFACiRNmxwAigADrKf8G6yVAt4gNdiygACJ1"
		. "RyAERk4hBIAtAFwAwQRAAAIiAIPHAmaLxAdm4BDT6UGAImAFkAcPhsdhUVD4gKgQBQ+HuoABD7fSEP8klRgCq/hcdAgK6aXBsgYC67+FwAr3zQpc"
		. "AOun4AJC3+0CYgDrj+ACx2HtAmYA6XTgq0ADrKFNA24A6VlDA5FNAxByAOk+QgMPhHJD4ADNA3QA6R9gAYCEPXCyXguNUODwDABedxHrQo1QgYmg"
		. "ACF2AXEfdzPABUPQMtsDdQDrA/ANiSJ04yEPtwcQIug8MZAE6cn+8ghAZY1KIXF9iQLptiAB/wYM6a+TAYsYAv8GgwTEDJEbw5BVMcARkRuNdezA"
		. "GwiLTQgIi1UgHBCJz2ZAwekEg+cP8Gq/AgRBFok8RkCD+CAEdeW4AwEm0nQAEIsKjXkCiTqAZos8RmaJOVAFgAOD6AFz5VpUIQDDkA=="
		if (32 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(4024), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 6396, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5008) {
			if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
				throw Error("Could not load dll " import[1] ": " OsError().Message)
			if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
				throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
			NumPut("Ptr", pFunction, code, offset)
		}
		for offset in [92, 227, 400, 406, 446, 452, 492, 498, 551, 587, 612, 790, 841, 908, 955, 1019, 1073, 1153, 1226, 1268, 1293, 1402, 1471, 1519, 1623, 1644, 1744, 1955, 2037, 2134, 2240, 2288, 2575, 2625, 2645, 2699, 2896, 2946, 3244, 3297, 3324, 3359, 3509, 4462, 4501, 4528, 4538, 4577, 4607, 4614, 4649, 4662, 4679, 5144, 5148, 5152, 5156, 5160, 5164, 5378, 5485, 5610, 5983, 6165, 6340]
			NumPut("Ptr", NumGet(code, offset, "Ptr") + code.Ptr, code, offset)
		if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
			throw Error("Failed to mark MCL memory as executable")
		lib := {
			code: code,
		dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
			DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
		loads: (this, ppJson, pResult) =>
			DllCall(this.code.Ptr + 2800, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
		}
		lib.DefineProp("bBoolsAsInts", {
			get: (this) => NumGet(this.code.Ptr + 4716, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 4716)
		})
		lib.DefineProp("bEscapeUnicode", {
			get: (this) => NumGet(this.code.Ptr + 4720, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 4720)
		})
		lib.DefineProp("bNullsAsStrings", {
			get: (this) => NumGet(this.code.Ptr + 4724, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 4724)
		})
		lib.DefineProp("fnCastString", {
			get: (this) => NumGet(this.code.Ptr + 4728, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 4728)
		})
		lib.DefineProp("fnGetArray", {
			get: (this) => NumGet(this.code.Ptr + 4732, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 4732)
		})
		lib.DefineProp("fnGetMap", {
			get: (this) => NumGet(this.code.Ptr + 4736, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 4736)
		})
		lib.DefineProp("objFalse", {
			get: (this) => NumGet(this.code.Ptr + 4740, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 4740)
		})
		lib.DefineProp("objNull", {
			get: (this) => NumGet(this.code.Ptr + 4744, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 4744)
		})
		lib.DefineProp("objTrue", {
			get: (this) => NumGet(this.code.Ptr + 4748, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 4748)
		})
		return lib
	}
	
	
	static _LoadLib64Bit() {
		static lib, code := Buffer(6800), codeB64 := ""
		. "+bgAQVdBVkFVQVQAVVdWU0iB7AgAAgAAiwFJic8ASInTTYnFRIkAzWaD+Ah0VH8iDgAcA3QoABQFdAhU6xQAHAkPhD6AAQAASI1JCAAaABR0IEiN"
		. "FcoVEAAA6Q8BKmNBCCBIjYwk0AEWiYQBAg5NiehIidroFBoXAEY4AM5Ii0koCOi8AQ0qAA3yDwAQQQgxwLkGAAAAAEUxyUiNvEQkuAJelCSgAAdF"
		. "ADHA86tIiw08ChMBE4QCG/IPEYQEJMAIYQ9XwEiLwAFIiVQkMAE3ARKgTIlMJEABBDgBVFEAGSgx0gE22AAbZtLHA0cFAAAE4AAEAAEgAMdEJCCB"
		. "A/9QRDAxgCaUJKiBFIsAFAJmhdIPhIABgTaF23QPSIsLAEyNQQJMiQNmAIkR6wRB/0UAQEiDwALrzYEOGgGJDgFI/8JmD76AAoTAdePrBgEUAOvt"
		. "SY1PCOkRg4ElgIFIOw22EoFqgBWbFAAAdSkDFigPhBSRNQGENf/CVOvXABxdAxxnChzbqwBfHRw0Axw0ChyiHg4IjQUHQAxIjVQkEmxAZEG5QUpI"
		. "iUQUJHDEXSjAFPkRAEQARMAEIEyNAAb/CFAoi0ALg/r/dRpqAAfcwG9EQz5JiwpHFYn1QRmF2w+EBDMJAUkDSI1QAgBIiRNmxwAiALAxwOkmQQUY"
		. "Kp2Abj0AkIBAJ8CEQH6ClUyNqKQkmIKX9oGAoIACLPOrQgbANacCRLwkorBCNIQkiIIFhMIQHkzAAcUFARDBokmLT1gIMf+BkEEICIGQqEcAAgJE"
		. "wUJ8JEABATgNwRTIwRBARDBMjQXE2xDBAmQkKAqahb3RwLiNBTyEIuDABIMnfwFHxCPBEgG3AQfHIwAWgq8AFoMlASWBCQhCEfhFJMFAxUyJdCRA"
		. "gWMBAtI4lCEx0qIQVsA44QfmEKJvYGeEJKEbYRBBCvkkKgULwA7tIgEQYQQAEOsDD0AhVEEhlKIJQhGjEIkLEGaD4y8DdQogAeK4IAEAdWOBAoEd"
		. "gwIa6IICU4ECQQkDdAmFgEqHQBXrJ0G8wIgKAAADGMEJdTXr5QVBRB11cel9/f//ocJx6kUx5CBzvMEGDQNHKEABAhxBg/wCMWMaTI20ApEhGotA"
		. "kCgPhcMCMT0dYA/MMfbhKWFf/Q7BG0OXj6NjYUehAQAEIP/Q4IlngQihYUCUFc6AJ4Vv7jj8//+ab0MTgWRFMfrbZ1qEohWDFIAT5EyjaRWBASiA"
		. "NGbAEkyJXJEhoVwkOCUu6dRDGK5soBCgecEziIU9vIMdraSwRAFionPwpXwTQArKROCqIMMc/9CGWMBH/2ERA29ltYEL4RRlr+V9IRZwjQXGDaRC"
		. "xbZFswPv4WpBvEE7qLRMgUqBAIIZfgNiYeASwCvBFEBJIBRxTg/gCMBBwQ4JdIachjb7/CyBAxsAP+A8ExkAwIPg4EiNSgIAg8B7SIkLZokiAgQF"
		. "jRVEwAtAhLjtdCUDCwBNmArbgzdGQOVKIWy8JFjFAUx7hAHDAnCrBCEaxAGDBYkA9/OrQA+2xTFi/8A7XEiLgG9ABDHG0oEmgQUMQEiAVcEn6kzg"
		. "OJChLhAjAwAyoC08WAzjL4Ep4TNRCUiL6IwkMHQZePIAgE2EGLfxCDAFkAH4FAPCdil0AE4oEwLxAZIeiwFBHujj9HjWPzHSSEEyNXsRMw4wgUrF"
		. "HWdAicaFwMB0B0iY6T+AHREc4aEoAw+FLHAC0AABeRAAD4Qe0ACF/3RKS2EXESpiLABGGp/rgCVBGmNEGkNPGkgakQJoOesfMQIsb0NjQ/8gxju0"
		. "JHCwB38PJfAFQvAF6+RSRNtBAeBu/4P4AQ+HXE8QCvATcRVhk3UnPwoiITUKY4QkSHAC6cG/QA1xlM8CyALAcsICnoI7zBXGgByRmHUvPyjvDabb"
		. "MR3hA+tYsAOTswO4CHUyoR9hAaR3KiFMwIXbdWTpguSA74wx7IxID79UJAApeEjQjUwkeMQELYE9/wyqAJQDI2oBOqIaIgABAgQCAUACIADrE5BB"
		. "i0UAIAL/wMABwA9FwkGJRbEVERgBMwZMiflEi0wkIFz/x//AUYfoKWD1///p5tBUJxgJjHUQVQ7gKf9QEBKsCAh1DlUB/xVDCjcyG1E4BwNgDwNU"
		. "Af8VnhIAA1YzMgJQFS8L8yZ6XAQZPA8ZCRmPJo8mALp9gSbZ0AaFJmEDHg9KIn0DSunc9nNt6dMRgABIgcQxvVteXwBdQVxBXUFeQXhfw5AIAHS/"
		. "sXbAQUGQuBMAgDA/AhSgHIDLSInWTIlKQGUAE2aLAo1I92YAg/kXdxNJD6MgyA+DlgRQD4PCCZEb696gEXsPhVfjQUhgTnwkaFOL4AEyu/SoB5Eh"
		. "EyRm4ZKBYYa6WFQkaHFq4FxEMImNnAW54gKSukhBSIuQUAGijANmixBmg/qIIH8mUAAIfwWAuUDrJYPqCbmxC0jAD6PRD4PP8AfhuCBIiQPrzlAC"
		. "InRCD1AAfQ+EqmFvsQfRAZAIIYtIidno+AD+//+FwA+FmadwARMQQwaNSioPekgFQSAP+joPhWcmAfLTgASAAeistARNkQHRfsUwBklRc/noQUCr"
		. "7wVIF3cP4QVzE6UF4gGgBSwPhD3///9gZoM4femxXQAWW9gPhakPFgMWN8EGARaW2wgWkBRvcAEx7ZwWD1WALxYmFoACXIlsJEJcFYxEJGC9cguN"
		. "KAVsCKEG+YE+YEiciwdEBFAA4d//BXEEqigoGiMiGguy0zrQAazrHIAaMBrV9w7RIAIwXQ+Et8IYYRToaPuAmTEUCQADMAYQhbWEMxt3xbtwCEAO"
		. "ilECwn9QC0i8ibQiAti4p4JBADDqpoA+CXUKSItOcZNv8DvPGc8ZwxlAwhlgC4WGZXIwwgFmxwYJkAgwfgjpNEABIBsiD2SFbwJzQgKgGjBNA+hI"
		. "iUbAsQZxsUAGcPMg+SIPhCoBHoXJiA+EGWADTI1AokBAg/lcD4UDoudIQgLQAGYPhIFQC39CMpEBdHF/GLEDdEJhUAAvD4XgcXLHQEL+LwDrdRAB"
		. "YogPhc4UAQgA6wC0EPl0dFcSA250RyFQAHIPha70AQ2ktgAA60Nmg/l1DwCFnAMAAEyNQAAESIPADEyJAwBmx0L+AADrTyEBOCIA6x4BHFwAhOsW"
		. "ARwMAOsOARyQCgDrBgEcCQAAaAAESIkD61lFjQBRv2ZBg/oFdwA0Qo1MCclJg0DAAmaJSv4AokkAOcB0OWaLSv4IweEEASRmRYsIBQBc0AEuCXfG"
		. "RAEo0evRAA+fAj4Ph0YMAI8BQqnruwEtSACDwgLpxv7//0BMi0YISI0BEMAAAkwpwUGJSPwDA6sAf+m7AgAAjQhQ0GYAUUEPlsAAZoP4LQ+UwkEA"
		. "CNAPhLQBAAAARTHJZscGFAACugALAEyJTghIAIsDZoM4LXUOYYEmSMfC/wAAgCNmBIsAAB0wdRIxyQ5IgxKCDwBwNoPoMWEADQgPh2wANQEMDyC/"
		. "CESNSYFi+QmAdxdMa04ICgQWAEmNRAnQSIlGQAjr12aLCICyLjR1VwENQQI/ABDySBAPKkYIgEgFAPIsDxEAa4BGi4gmKUWAa9IKRQ+/yYEaYPJB"
		. "DyrBARqAA8oA8g9ewfIPWEaCCIIb68aD4d+ALzBFD4WbgSwDP2aDMD4UdRCTMQAWLXQICUUxgJD5K3UHSUUMizhASI1PwE/5cAkPh4qAKYAExAN3"
		. "MBNFa8mCNgEkiQMAQQHJ6+ExybgBwTJBOcl+B2vAAAr/wev08g8qAMjyDxBGCEWECMB0BgEq6wTyD6ZZgCtAH4sGAE8UgFsAD69WCEiJVggE6QkB"
		. "GYP4BQ+FNv8AEgAPwgALxDXp7DFBM40NhICCwAh0dSBMZg++AYAVGEgAixNmOwIPhechgjvCAkj/gEYT6xDggD3rQAQAdBKBADwDAEjHRgiBJxzp"
		. "pAABQATAqYsNSylABOmjAxYwAxZmdapEDRaODhaSAhYNgEwrghaBdVDFFNeAButSjQAU5QCFABRudVEEFBIUAxR1QQgT5IA9JmUCEwAHBdzBP8cG"
		. "QghCFDHA6x3FFJMDwogBnwH/UAjr5CK4wqaBxLjABVte8F9dw5ACAME3CQDdA/8/AB8AHwAfAB8AHwAfAB8AFx8AHwAJABBgAE8AdwAAbgBQAHIA"
		. "b7AAcABznwYIAAhgAKhQAHWgBmjyAwZgACBTAGUAdPQHMDEAMjM0NTY3ODlAQUJDREVGYQLyraBWckBhwWGSYAARYAACT2AAIlVua25vAHduX1Zh"
		. "bHVlAF8AdHJ1ZQBmAGFsc2UAbnVsoGwASABh4BBNog0aaGAZZGAJZgZPYmpQZWN0X7EdXyAARRFgAnUAbaABDQoAGAkAIsUF5gdUeXADQA5uHVZT"
		. "SIHsqCEAATHAQbnjqJQkAsjCeVQkVEyJw4BIic6JRCRUwGYITI2EIwOJVCQoBDHSoAAgSI0VW8L94GhQKIsDYLtABhBYD1fAwsKEJIihwitMjQU4"
		. "QARmgAgAcEiLQwgPEUSIJGBIoAF4SIvjCTDHRCRoICbgCoQkDpAiD0EFIARYSIsGoEiJTCRAgQA4gQAwMEiJ8cQPoAYgBAGgBf9QMGaDOwkgdQtI"
		. "i0uDexCQQ8B6QRpbXsOQ4BuDIOw4QboTwaq7CiHBC4sBSIWgjkQkAC4AAEmJ0UiNAEwkBnkyQboUEYEDmbswwABJ9/sAKdNMidJmQolAXFH+Sf/K"
		. "IAZ1gOONQv5IY9AgBwBUBi0A6xpImZHABIPCMIAEFFGABQHEBOiJ0EiYSAEAwEgBwWaLAWYAhcB0HU2FyXQAD0mLEUyNUgIATYkRZokC6wMEQf8A"
		. "UcEC69sx4MBIg8Q4sQoBAPIKAChIictIhdJ0gBFIiwJIjUiwZDAKZscAYINSA401BpsBFYBnhcAPhI4RA18NdyNQAAcPhmIR8ACNSPggZkB/BAHA"
		. "AA+3yUhjDI4gSAHx/+EgAiJ0wgtQAFx0LenCXlAGahpTBgQgBlxAGKAGQCACIgDpLLADQYOwAALpI4AAcQLyfwKwAlwA6TEG4QHT7wGgAmIA6eVU"
		. "BrTvAaACZgDpxuQBle8BIAJuAOmn4wEPhIZy0VovAnIA6YQlAgZPLwIhAnQA62SAAD0z+v//AHQLCI1I4JARXncR65A5jUiBoAAhdiF0KB93KkEI"
		. "F+8DAnUIAOsEYRAPtwvoCk9xaReRAg9IiwogTI1JAkxAAokB4dQcwwLpZhCVnxuVGziDxCh1HgUA0B4YMcDATI0ds/uwmKAogAhJicpmwekwBwDi"
		. "D2ZHD74UE4BmRYkUQUj/YCJg+AR14biARBITFRUiCFEgCBKgnxRBZghEiRFkBugBc90BYiUYww=="
		if (64 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(4003), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 6800, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5456) {
			if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
				throw Error("Could not load dll " import[1] ": " OsError().Message)
			if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
				throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
			NumPut("Ptr", pFunction, code, offset)
		}
		if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
			throw Error("Failed to mark MCL memory as executable")
		lib := {
			code: code,
		dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
			DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
		loads: (this, ppJson, pResult) =>
			DllCall(this.code.Ptr + 3072, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
		}
		lib.DefineProp("bBoolsAsInts", {
			get: (this) => NumGet(this.code.Ptr + 5056, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5056)
		})
		lib.DefineProp("bEscapeUnicode", {
			get: (this) => NumGet(this.code.Ptr + 5072, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5072)
		})
		lib.DefineProp("bNullsAsStrings", {
			get: (this) => NumGet(this.code.Ptr + 5088, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5088)
		})
		lib.DefineProp("fnCastString", {
			get: (this) => NumGet(this.code.Ptr + 5104, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5104)
		})
		lib.DefineProp("fnGetArray", {
			get: (this) => NumGet(this.code.Ptr + 5120, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5120)
		})
		lib.DefineProp("fnGetMap", {
			get: (this) => NumGet(this.code.Ptr + 5136, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5136)
		})
		lib.DefineProp("objFalse", {
			get: (this) => NumGet(this.code.Ptr + 5152, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5152)
		})
		lib.DefineProp("objNull", {
			get: (this) => NumGet(this.code.Ptr + 5168, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5168)
		})
		lib.DefineProp("objTrue", {
			get: (this) => NumGet(this.code.Ptr + 5184, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5184)
		})
		return lib
	}
	
	static _LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

    static Stringify(obj) => this.Dump(obj)
    static DumpFile(obj, path, pretty := 0, encoding?)
        => FileOpen(path, "w", encoding?).Write(this.Dump(obj, pretty))

    /**
     * Convert an object to a JSON string
     *
     * @param obj The object to convert
     * @param pretty Whether to pretty-print the JSON string (default: 0)
     *
     * @return The JSON string
     */
    static Dump(obj, pretty := 0)
    {
        variant_buf := Buffer(24, 0)  ; Make a buffer big enough for a VARIANT.
        var := ComValue(0x400C, variant_buf.ptr)  ; Make a reference to a VARIANT.
        var[] := obj

        size := 0
        this.lib.dumps(variant_buf, 0, &size, !!pretty, 0)
        buf := Buffer(size*5 + 2, 0)
        bufbuf := Buffer(A_PtrSize)
        NumPut("Ptr", buf.Ptr, bufbuf)
        this.lib.dumps(variant_buf, bufbuf, &size, !!pretty, 0)

        ; If a VARIANT contains a string or object, it must be explicitly freed
        ; by calling VariantClear or assigning a pure numeric value:
        var[] := 0
        return StrGet(buf, "UTF-16")
    }

    static Parse(json) => this.Load(json)
    static LoadFile(path, options?) => this.Load(FileRead(path, options?))

    /**
     * Parse a JSON string into an object
     *
     * @param json The JSON string to parse
     *
     * @return The parsed object
     */
    static Load(json) {
        ; Prefix with a space to provide room for BSTR prefixes
        _json := " " (json is VarRef ? %json% : json)
        pJson := Buffer(A_PtrSize)
        NumPut("Ptr", StrPtr(_json), pJson)

        pResult := Buffer(24)

        if r := this.lib.loads(pJson, pResult)
        {
            throw Error("Failed to parse JSON (" r ")", -1
            , Format("Unexpected character at position {}: '{}'"
            , (NumGet(pJson, 'UPtr') - StrPtr(_json)) // 2, Chr(NumGet(NumGet(pJson, 'UPtr'), 'Short'))))
        }

        result := ComValue(0x400C, pResult.Ptr)[] ; VT_BYREF | VT_VARIANT
        if IsObject(result)
            ObjRelease(ObjPtr(result))
        return result
    }

    /**
     * Object to act as a stand-in for JSON's "true" as AHK has no native
     * boolean type.
     *
     * @see {@link JSON.BoolsAsInts}
     */
    static True {
        get {
            static _ := {value: true, name: 'true'}
            return _
        }
    }

    /**
     * Object to act as a stand-in for JSON's "false" as AHK has no native
     * boolean type.
     *
     * @see {@link JSON.BoolsAsInts}
     */
    static False {
        get {
            static _ := {value: false, name: 'false'}
            return _
        }
    }

    /**
     * Object to act as a stand-in for JSON's "null" as AHK has no native
     * null type.
     *
     * @see {@link JSON.NullsAsStrings}
     */
    static Null {
        get {
            static _ := {value: '', name: 'null'}
            return _
        }
    }
}


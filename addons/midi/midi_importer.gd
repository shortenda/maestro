tool
extends EditorImportPlugin

enum Presets { PRESET_DEFAULT }

const FileBytes = preload("res://addons/midi/sound_font_bytes.gd")

func get_importer_name( ):
    return "midi.plugin"

func get_visible_name( ):
    return "MidiImporter"

func get_recognized_extensions( ):
    return ["mid"]

func get_save_extension( ):
    return "res"

func get_resource_type( ):
    return "Resource"

func get_preset_count( ):
    return Presets.size()

func get_preset_name( preset:int ):
    match preset:
        Presets.PRESET_DEFAULT:
            return "Default"
        _:
            return "Unknown"

func get_import_options( preset:int ):
    match preset:
        Presets.PRESET_DEFAULT:
            return [{
                       "name": "default",
                       "default_value": false
                    }]
        _:
            return []

func get_option_visibility( option:String, options:Dictionary ):
    return true

func import( source_file:String, save_path:String, s:Dictionary, platform_variants:Array, gen_files:Array ) -> int:
    var f:File = File.new( )

    var err:int = f.open( source_file, f.READ )
    if err != OK:
        return err

    var sound_font_bytes = FileBytes.new()
    sound_font_bytes.value = f.get_buffer(f.get_len())
    var ret = ResourceSaver.save( "%s.%s" % [save_path, self.get_save_extension( )], sound_font_bytes, ResourceSaver.FLAG_COMPRESS )
    f.close()
    return ret

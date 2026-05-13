import re
def convert_svg_classes_to_inline(input_path, output_path):
    with open(input_path, 'r') as f:
        content = f.read()
    style_match = re.search(r'<style>(.*?)</style>', content, re.DOTALL)
    if not style_match:
        print("No style found"); return
    
    style_block = style_match.group(1)
    classes = {}
    for match in re.finditer(r'\.(cls-[\w-]+)\{([^}]+)\}', style_block):
        props = {}
        for prop in match.group(2).split(';'):
            prop = prop.strip()
            if ':' in prop:
                k, v = prop.split(':', 1)
                props[k.strip()] = v.strip()
        classes[match.group(1)] = props
    
    def replace_class(m):
        tag_content = m.group(0)
        cls_match = re.search(r'class="([^"]*)"', tag_content)
        if not cls_match:
            return tag_content
        style_parts = []
        for cn in cls_match.group(1).split():
            if cn in classes:
                for k, v in classes[cn].items():
                    style_parts.append(f"{k}:{v}")
        if style_parts:
            new_style = ';'.join(style_parts)
            tag_content = re.sub(r' class="[^"]*"', f' style="{new_style}"', tag_content)
        return tag_content
    
    result = re.sub(r'<(path|rect|circle|ellipse|polygon|polyline|line|text)[^>]*>', replace_class, content)
    result = re.sub(r'<defs><style>.*?</style></defs>', '<defs/>', result, flags=re.DOTALL)
    
    with open(output_path, 'w') as f:
        f.write(result)
# Jalankan:
convert_svg_classes_to_inline('assets/images/NewLogoBiru.svg',   'assets/logo/NewLogoBiru_fixed.svg')
convert_svg_classes_to_inline('assets/images/NewLogoEmblem.svg', 'assets/logo/NewLogoEmblem_fixed.svg')
convert_svg_classes_to_inline('assets/images/NewLogoEmblem.svg', 'assets/logo/NewLogoEmblem2_fixed.svg')
convert_svg_classes_to_inline('assets/images/NewLogoPutih.svg',  'assets/logo/NewLogoPutih_fixed.svg')
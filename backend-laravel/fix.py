import re

with open('d:/s4/PROJEK-ACTIVA/backend-laravel/resources/views/web/kuesioner.blade.php', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = re.compile(
    r'<div class=\"k-opt-grid\" data-name=\"([^\"]+)\">\s*'
    r'@foreach\(\[(.*?)\] as \$val=>\$lbl\)\s*'
    r'@php \[\$l,\$d\]=explode\(\'\|\',\$lbl\); @endphp\s*'
    r'<div class=\"k-opt-btn \{\{ old\(\'(.*?)\'\) == \$val \? \'selected\' : \'\' \}\}\" data-value=\"\{\{ \$val \}\}\" data-desc=\"\{\{ \$d \}\}\">\s*'
    r'\{\{ \$l \}\}\s*'
    r'</div>\s*'
    r'@endforeach\s*'
    r'</div>\s*'
    r'<div class=\"k-opt-desc\" id=\"desc-\1\">.*?</div>'
)

def replace_fn(m):
    return f'''<div class=\"k-opt-group\" data-name=\"{m.group(1)}\">
                        @foreach([{m.group(2)}] as $val=>$lbl)
                        @php [$l,$d]=explode('|',$lbl); @endphp
                        <div class=\"k-opt-card {{{{ old('{m.group(3)}') == $val ? 'selected' : '' }}}}\" data-value=\"{{{{ $val }}}}\">
                            <div class=\"k-opt-radio\"></div>
                            <div class=\"k-opt-body\">
                                <div class=\"k-opt-main\">{{{{ $l }}}}</div>
                                <div class=\"k-opt-sub\">{{{{ $d }}}}</div>
                            </div>
                        </div>
                        @endforeach
                    </div>'''

new_content = pattern.sub(replace_fn, content)

new_content = new_content.replace('.k-opt-btn', '.k-opt-card')
new_content = new_content.replace('.k-opt-grid', '.k-opt-group')
new_content = re.sub(
    r'/\* show description below \*/.*?\}\)',
    '});', new_content, flags=re.DOTALL
)

with open('d:/s4/PROJEK-ACTIVA/backend-laravel/resources/views/web/kuesioner.blade.php', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Done")

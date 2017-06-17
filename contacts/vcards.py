def split_long_lines(lines, length=75):
    short_lines = []
    for line in lines:
        short_lines.append(line[:length])
        if len(line) > length:
            sublines = [line[length:][i:i + length - 1] for i in range(0, len(line), length - 1)]
            short_lines += [' ' + subline for subline in sublines if subline]
    return short_lines


class Vcard(object):
    def __init__(self, address_book, content):
        self.address_book = address_book
        self.dict = {}

        for key, value in content:
            if key not in self.dict:
                self.dict[key] = [value]
            else:
                self.dict[key].append(value)

    def __str__(self):
        return self.dict['FN'][0]

    def __eq__(self, other):
        return dict(self.dict) == dict(other.dict)

    @property
    def uid(self):
        return self.dict['UID' if 'UID' in self.dict else 'FN'][0]

    def dict_items(self):
        return [(key, v) for key in self.dict for v in self.dict[key]]

    def fmt_dict(self):
        return split_long_lines(['%s:%s' % item for item in self.dict_items()])

    def fmt(self):
        return '\n'.join(['BEGIN:VCARD'] + self.fmt_dict() + ['END:VCARD'])

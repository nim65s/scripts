from uuid import uuid4


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
        return self.dict['FN'][0] if 'FN' in self.dict else '???'

    def __repr__(self):
        return f'<Vcard for {self}>'

    def __eq__(self, other):
        if self.uid == other.uid:
            return True
        sd, od = self.dict.copy(), other.dict.copy()
        sd.update(UID='', PRODID='', REV='')
        od.update(UID='', PRODID='', REV='')
        return sd == od

    @property
    def uid(self):
        for id in ['UID', 'FN']:
            if id in self.dict:
                return self.dict[id][0]
        return uuid4()

    def dict_items(self):
        d_i = [(key, v) for key in self.dict for v in self.dict[key]]
        if 'UID' not in self.dict:
            d_i.append(('UID', uuid4()))
        return sorted(d_i)

    def fmt_dict(self):
        return split_long_lines(['%s:%s' % item for item in self.dict_items()])

    def fmt(self):
        return '\n'.join(['BEGIN:VCARD'] + self.fmt_dict() + ['END:VCARD'])

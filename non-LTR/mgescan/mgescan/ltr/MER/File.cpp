#include <string.h>
#include "lib.h"
#include "File.h"


File::File()
{
}

File::~File()
{
}

const char* File::getName(const char* filePath)
{
	ASSERT(filePath);

	const char* p = strrchr(filePath, '/');
	return (p == NULL) ? filePath : p+1;
}

void File::getName(const char* filePath, char* filename)
{
	ASSERT(filePath); ASSERT(filename);

	const char* p = strrchr(filePath, '/');
	if (p == NULL) p = filePath-1;
	strcpy(filename, p+1);
}

void File::getNameWithoutExt(const char* filePath, char* filename)
{
	ASSERT(filePath); ASSERT(filename);

	const char* p = getName(filePath);
	const char* q = getExtension(filePath);

	for ( q--; p < q; p++, filename++) *filename = *p;
	*filename = '\0';
}

const char* File::getExtension(const char* filePath)
{
	ASSERT(filePath);

	const char* p = strrchr(filePath, '.');
	if (p == NULL) p = filePath + strlen(filePath); 
	else           p++;
	return p;
}


#include <math.h>
#include <stdio.h>

int main() {
    // Set the names of input and output files
    const char* trackFileName = "Bad_Track";
    const char* outFileName = "Track_Gradient.txt";

    // Open I/O files
    FILE *trackFile = fopen(trackFileName, "r");
    FILE *outFile = fopen(outFileName, "w");

    if (trackFile == NULL || outFile == NULL) {
        perror("Error al abrir archivos");
        return 1;
    }

    // Variables to store data
    double Xm, Ym, DX, DY, DZ, Distance, Gradient, Azimuth, Radians;

    // Variables to read coordinates from each line
    double x1, y1, z1, x2, y2, z2;

    // Read coordinates from first line
    if (fscanf(trackFile, "%lf %lf %lf", &x1, &y1, &z1 ) != 3) {
        perror("Error al leer el archivo de entrada");
        return 1;
    }

    // Loop to process each line
    while (fscanf(trackFile, "%lf %lf %lf" , &x2, &y2, &z2) == 3) {
        // 1. Calculate middle point
        Xm = (x1 + x2) / 2.0;
        Ym = (y1 + y2) / 2.0;

        // 2. Gradient
        DX= (x2-x1);
        DY= (y2-y1);
        Distance= sqrt(pow(DX, 2) + pow(DY, 2));
        DZ = (z2-z1);
        Gradient= (DZ / Distance);
       
        // 3. Azimuth
        Radians = atan2 (DX, DY);
        Azimuth = fmod ((Radians * (180/M_PI)+360),360);

        // Write output file
        fprintf(outFile, "%.2f %.2f %.5f %.4f\n", Xm, Ym, Gradient, Azimuth);

        // Update coordinates for next line.
        x1 = x2;
        y1 = y2;
        z1 = z2;
    }

    // Close files
    fclose(trackFile);
    fclose(outFile);

    printf("Proceso completado con éxito.\n");

    return 0;
}
